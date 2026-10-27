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
    $typeName = 'RunnerCaptureWin32'
    if (-not ([System.Management.Automation.PSTypeName]$typeName).Type) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class RunnerCaptureWin32 {
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr window, int x, int y, int width, int height, bool repaint);
}
"@
    }
    [RunnerCaptureWin32]::MoveWindow($Window, $target.X + $Margin, $target.Y + $Margin, $Width, $Height, $true) | Out-Null
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
