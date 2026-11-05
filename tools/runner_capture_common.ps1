# Shared helpers for GameMaker Runner launch and window capture.
# Dot-source from tools/*.ps1: . (Join-Path $PSScriptRoot 'runner_capture_common.ps1')

function Get-GamemakerRunnerExe {
    if ($env:GMS2_RUNNER_EXE) {
        $override = $env:GMS2_RUNNER_EXE.Trim()
        if (Test-Path -LiteralPath $override) {
            return (Resolve-Path -LiteralPath $override).Path
        }
        throw "GMS2_RUNNER_EXE is set but file not found: $override"
    }

    $runtimeRoot = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes'
    if (-not (Test-Path -LiteralPath $runtimeRoot)) {
        throw "GameMaker runtime cache not found: $runtimeRoot. Set GMS2_RUNNER_EXE to your windows\x64\Runner.exe."
    }

    $runners = @(Get-ChildItem -LiteralPath $runtimeRoot -Directory |
        Sort-Object Name -Descending |
        ForEach-Object {
            $candidate = Join-Path $_.FullName 'windows\x64\Runner.exe'
            if (Test-Path -LiteralPath $candidate) { $candidate }
        })

    if ($runners.Count -eq 0) {
        throw "No windows\x64\Runner.exe found under $runtimeRoot"
    }

    return $runners[0]
}

function Get-RunnerProbeGameFile {
    param([string]$PreferredGameFile)

    if ($PreferredGameFile -and (Test-Path -LiteralPath $PreferredGameFile)) {
        return (Resolve-Path -LiteralPath $PreferredGameFile).Path
    }

    $blank = 'D:\final_project\Build\blank_runner.win'
    if (Test-Path -LiteralPath $blank) {
        return (Resolve-Path -LiteralPath $blank).Path
    }

    $buildDir = 'D:\final_project\Build'
    if (Test-Path -LiteralPath $buildDir) {
        $any = Get-ChildItem -LiteralPath $buildDir -Filter '*.win' -ErrorAction SilentlyContinue |
            Sort-Object Length |
            Select-Object -First 1
        if ($any) { return $any.FullName }
    }

    throw 'No .win package found for Runner launch probe. Build the project or pass -GameFile.'
}

function Test-GamemakerRunnerLaunch {
    param(
        [Parameter(Mandatory)][string]$RunnerExe,
        [Parameter(Mandatory)][string]$GameFile,
        [int]$ProbeMilliseconds = 800
    )

    $report = [ordered]@{
        RunnerExe = $RunnerExe
        GameFile = $GameFile
        ProcessStarted = $false
        CanLaunch = $false
        MainWindowHandle = 0
        ExitCode = $null
        NativeErrorCode = $null
        ErrorMessage = $null
        RestrictedEnvironmentLikely = $false
    }

    $process = $null
    try {
        $process = Start-Process -FilePath $RunnerExe -ArgumentList @('-game', $GameFile) `
            -WorkingDirectory (Split-Path -LiteralPath $GameFile) -PassThru -ErrorAction Stop
        $report.ProcessStarted = $true
        Start-Sleep -Milliseconds $ProbeMilliseconds
        $process.Refresh()
        if ($process.HasExited) {
            $report.ExitCode = $process.ExitCode
            $report.ErrorMessage = "Runner exited during probe (exit $($process.ExitCode))."
            return $report
        }
        $report.MainWindowHandle = [int64]$process.MainWindowHandle
        $report.CanLaunch = $true
    } catch {
        $report.ErrorMessage = $_.Exception.Message
        $win32 = $_.Exception -as [System.ComponentModel.Win32Exception]
        if ($null -ne $win32) {
            $report.NativeErrorCode = $win32.NativeErrorCode
        }
        if ($report.NativeErrorCode -eq 623 -or
            $report.ErrorMessage -match 'DLL|relocation') {
            $report.RestrictedEnvironmentLikely = $true
        }
    } finally {
        if ($null -ne $process -and -not $process.HasExited) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }

    return $report
}

function Assert-GamemakerRunnerLaunchEnvironment {
    param(
        [string]$GameFile,
        [switch]$SkipCheck
    )

    if ($SkipCheck) { return }

    $runner = Get-GamemakerRunnerExe
    $probeGame = Get-RunnerProbeGameFile -PreferredGameFile $GameFile
    $result = Test-GamemakerRunnerLaunch -RunnerExe $runner -GameFile $probeGame

    if ($result.CanLaunch) { return }

    $doc = 'docs/devlog/2026-10-16-runner-dll-diagnosis/after/README.md'
    $procedure = 'docs/devlog/2026-10-22-runner-capture-procedure/README.md'
    $hint = if ($result.RestrictedEnvironmentLikely) {
        'This matches the restricted-process / sandbox failure (Windows DLL relocation), not a game build defect.'
    } else {
        'Runner did not stay running; check runtime install, .win path, and architecture (use windows\x64\Runner.exe).'
    }

    $codePart = if ($null -ne $result.NativeErrorCode) { " NativeErrorCode=$($result.NativeErrorCode)." } else { '' }
    throw @"
GameMaker Runner launch probe failed. $hint
Probe game: $($result.GameFile)
Runner: $($result.RunnerExe)
Detail: $($result.ErrorMessage).$codePart
Run capture and launch commands from an interactive desktop PowerShell (see $procedure and $doc).
Use tools/test_runner_launch.ps1 to record environment diagnostics before capture.
"@
}

function Get-CaptureMonitorWorkingArea {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $display2 = $screens | Where-Object { $_.DeviceName -match 'DISPLAY2' } | Select-Object -First 1
    if ($display2) { return $display2.WorkingArea }
    $secondary = $screens | Where-Object { -not $_.Primary } | Select-Object -First 1
    if ($secondary) { return $secondary.WorkingArea }
    return [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
}

function Move-RunnerToCaptureMonitor {
    param(
        [Parameter(Mandatory)][IntPtr]$Window,
        [int]$Width = 1280,
        [int]$Height = 750,
        [int]$Margin = 20
    )

    $target = Get-CaptureMonitorWorkingArea
    Initialize-RunnerCaptureWin32
    [RunnerCaptureWin32]::MoveWindow($Window, $target.X + $Margin, $target.Y + $Margin, $Width, $Height, $true) | Out-Null
    [RunnerCaptureWin32]::ShowWindow($Window, 9) | Out-Null
    return $target
}

function Remove-StaleRunnerDebugSidecar {
    param([Parameter(Mandatory)][string]$GameFile)
    $sidecar = [System.IO.Path]::ChangeExtension($GameFile, ".yydebug")
    if (Test-Path -LiteralPath $sidecar) {
        Remove-Item -LiteralPath $sidecar -Force -ErrorAction SilentlyContinue
    }
}

function Start-GamemakerRunnerProcess {
    param(
        [Parameter(Mandatory)][string]$RunnerExe,
        [Parameter(Mandatory)][string]$GameFile,
        [string]$RedirectStandardOutput,
        [string]$RedirectStandardError
    )

    $params = @{
        FilePath = $RunnerExe
        ArgumentList = @('-game', $GameFile)
        WorkingDirectory = Split-Path -LiteralPath $GameFile
        PassThru = $true
    }
    if ($RedirectStandardOutput) { $params.RedirectStandardOutput = $RedirectStandardOutput }
    if ($RedirectStandardError) { $params.RedirectStandardError = $RedirectStandardError }
    return Start-Process @params
}

function Initialize-RunnerCaptureWin32 {
    if (([System.Management.Automation.PSTypeName]'RunnerCaptureWin32').Type) { return }

    Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class RunnerCaptureWin32 {
    [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X; public int Y; }
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdc, uint nFlags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT lpPoint);
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    public static IntPtr FindGameWindow(uint processId) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((hWnd, lParam) => {
            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);
            if (pid != processId) return true;
            var cls = new StringBuilder(256);
            GetClassName(hWnd, cls, cls.Capacity);
            if (cls.ToString() == "YYGameMakerYY") {
                found = hWnd;
                return false;
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }
}
"@
}

function Wait-GamemakerRunnerGameWindow {
    param(
        [Parameter(Mandatory)]$Process,
        [int]$MaxRetries = 80,
        [int]$RetryMilliseconds = 100
    )

    Initialize-RunnerCaptureWin32
    for ($retry = 0; $retry -lt $MaxRetries; $retry++) {
        Start-Sleep -Milliseconds $RetryMilliseconds
        $Process.Refresh()
        if ($Process.HasExited) {
            throw "Runner exited before game window appeared (exit $($Process.ExitCode))"
        }
        $window = [RunnerCaptureWin32]::FindGameWindow([uint32]$Process.Id)
        if ($window -ne [IntPtr]::Zero -and [RunnerCaptureWin32]::IsWindow($window)) {
            return $window
        }
    }

    throw 'GameMaker Runner window (YYGameMakerYY) did not appear'
}

function Show-RunnerCaptureWindow {
    param([Parameter(Mandatory)][IntPtr]$Window)

    Initialize-RunnerCaptureWin32
    [RunnerCaptureWin32]::ShowWindow($Window, 9) | Out-Null
    [RunnerCaptureWin32]::SetForegroundWindow($Window) | Out-Null
}

function Test-RunnerCaptureBitmapBlank {
    param(
        [Parameter(Mandatory)][System.Drawing.Bitmap]$Bitmap,
        [int]$SamplePoints = 12
    )

    $width = $Bitmap.Width
    $height = $Bitmap.Height
    if ($width -lt 4 -or $height -lt 4) { return $true }

    $first = $Bitmap.GetPixel([int]($width / 2), [int]($height / 2))
    $same = $true
    for ($i = 0; $i -lt $SamplePoints; $i++) {
        $x = [int](($width - 1) * ($i + 1) / ($SamplePoints + 1))
        $y = [int](($height - 1) * (($i * 3 + 1) % ($SamplePoints + 1)) / ($SamplePoints + 1))
        $pixel = $Bitmap.GetPixel($x, $y)
        if ($pixel.R -ne $first.R -or $pixel.G -ne $first.G -or $pixel.B -ne $first.B) {
            $same = $false
            break
        }
    }
    return $same
}

function Save-RunnerClientFrame {
    param(
        [Parameter(Mandatory)][IntPtr]$Window,
        [Parameter(Mandatory)][string]$OutputPath,
        [int]$ClientWidth = 1280,
        [int]$ClientHeight = 720,
        [ValidateSet('PrintWindow', 'BitBlt', 'Auto')][string]$CaptureMode = 'Auto'
    )

    Initialize-RunnerCaptureWin32
    if (-not [RunnerCaptureWin32]::IsWindow($Window)) {
        throw 'Runner capture window handle is invalid (ERROR_INVALID_WINDOW_HANDLE)'
    }

    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    $methodUsed = $null
    $frameOutputPath = $OutputPath

    function Save-BitmapFile([System.Drawing.Bitmap]$Image) {
        $dir = Split-Path -Path $frameOutputPath -Parent
        if ($dir -and -not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
        $Image.Save($frameOutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }

    function Copy-RunnerClientFromScreen {
        $clientRect = New-Object RunnerCaptureWin32+RECT
        if (-not [RunnerCaptureWin32]::GetClientRect($Window, [ref]$clientRect)) {
            throw 'GetClientRect failed for Runner window'
        }
        $width = $clientRect.Right - $clientRect.Left
        $height = $clientRect.Bottom - $clientRect.Top
        if ($width -lt 64 -or $height -lt 64) {
            throw "Runner client area too small: ${width}x${height}"
        }
        $origin = New-Object RunnerCaptureWin32+POINT
        $origin.X = 0
        $origin.Y = 0
        if (-not [RunnerCaptureWin32]::ClientToScreen($Window, [ref]$origin)) {
            throw 'ClientToScreen failed for Runner window'
        }
        $screenBitmap = [System.Drawing.Bitmap]::new($width, $height)
        $screenGraphics = [System.Drawing.Graphics]::FromImage($screenBitmap)
        try {
            $screenGraphics.CopyFromScreen($origin.X, $origin.Y, 0, 0, [System.Drawing.Size]::new($width, $height))
        } finally {
            $screenGraphics.Dispose()
        }
        if (Test-RunnerCaptureBitmapBlank -Bitmap $screenBitmap) {
            $screenBitmap.Dispose()
            throw 'Runner frame capture produced a uniform blank bitmap'
        }
        if ($width -eq $ClientWidth -and $height -eq $ClientHeight) {
            Save-BitmapFile $screenBitmap
            $screenBitmap.Dispose()
        } else {
            $scaled = New-Object System.Drawing.Bitmap $ClientWidth, $ClientHeight
            $scaleGraphics = [System.Drawing.Graphics]::FromImage($scaled)
            try {
                $scaleGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $scaleGraphics.DrawImage($screenBitmap, 0, 0, $ClientWidth, $ClientHeight)
            } finally {
                $scaleGraphics.Dispose()
                $screenBitmap.Dispose()
            }
            Save-BitmapFile $scaled
            $scaled.Dispose()
        }
        return 'BitBlt'
    }

    if ($CaptureMode -eq 'BitBlt' -or $CaptureMode -eq 'Auto') {
        try {
            $methodUsed = Copy-RunnerClientFromScreen
        } catch {
            if ($CaptureMode -eq 'BitBlt') { throw }
        }
    }

    if ($null -eq $methodUsed -and ($CaptureMode -eq 'PrintWindow' -or $CaptureMode -eq 'Auto')) {
        $outerHeight = $ClientHeight + 30
        $whole = [System.Drawing.Bitmap]::new($ClientWidth, $outerHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($whole)
        try {
            $dc = $graphics.GetHdc()
            try {
                $captured = [RunnerCaptureWin32]::PrintWindow($Window, $dc, 2)
            } finally {
                $graphics.ReleaseHdc($dc) | Out-Null
            }
            if ($captured) {
                $client = $whole.Clone(
                    [System.Drawing.Rectangle]::new(0, 30, $ClientWidth, $ClientHeight),
                    $whole.PixelFormat)
                try {
                    if (-not (Test-RunnerCaptureBitmapBlank -Bitmap $client)) {
                        Save-BitmapFile $client
                        $methodUsed = 'PrintWindow'
                    }
                } finally {
                    $client.Dispose()
                }
            }
        } finally {
            $graphics.Dispose()
            $whole.Dispose()
        }
    }

    if ($null -eq $methodUsed) {
        throw 'Runner frame capture failed (BitBlt and PrintWindow)'
    }

    return $methodUsed
}
