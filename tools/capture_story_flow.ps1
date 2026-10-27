param(
    [Parameter(Mandatory)][string]$GameFile,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [int]$Frames = 360,
    [int]$PlayerShotFrame = 180,
    [switch]$PrepareCue,
    [int]$ShotStartX = 380,
    [int]$ShotStartY = 350,
    [switch]$CaptureSettings,
    [ValidateSet('Story','Endless','Classic')][string]$Mode = 'Story',
    [int]$ResultReturnX = 640,
    [int]$ResultReturnY = 680,
    [switch]$DirectStory,
    [switch]$ResultReturn
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')
Assert-GamemakerRunnerLaunchEnvironment -GameFile $GameFile
Remove-StaleRunnerDebugSidecar -GameFile $GameFile
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class StoryFlowWin32 {
    [StructLayout(LayoutKind.Sequential)] public struct Point { public int X; public int Y; }
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr window, IntPtr dc, uint flags);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr window, ref Point point);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr window);
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr window, int x, int y, int width, int height, bool repaint);
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr window, uint message, UIntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
}
'@

function Move-ClientCursor([IntPtr]$Window, [int]$X, [int]$Y) {
    $point = [StoryFlowWin32+Point]::new()
    $point.X = $X
    $point.Y = $Y
    if (-not [StoryFlowWin32]::ClientToScreen($Window, [ref]$point)) { throw 'ClientToScreen failed' }
    [StoryFlowWin32]::SetCursorPos($point.X, $point.Y) | Out-Null
}

function Click-Client([IntPtr]$Window, [int]$X, [int]$Y) {
    [StoryFlowWin32]::SetForegroundWindow($Window) | Out-Null
    Move-ClientCursor $Window $X $Y
    $position = [IntPtr](($Y -shl 16) -bor ($X -band 65535))
    [StoryFlowWin32]::PostMessage($Window, 512, [UIntPtr]::Zero, $position) | Out-Null
    Start-Sleep -Milliseconds 120
    [StoryFlowWin32]::PostMessage($Window, 513, [UIntPtr]::new([uint32]1), $position) | Out-Null
    [StoryFlowWin32]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 80
    [StoryFlowWin32]::PostMessage($Window, 514, [UIntPtr]::Zero, $position) | Out-Null
    [StoryFlowWin32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
}

function Shoot-Player([IntPtr]$Window) {
    [StoryFlowWin32]::SetForegroundWindow($Window) | Out-Null
    Move-ClientCursor $Window $ShotStartX $ShotStartY
    Start-Sleep -Milliseconds 100
    [StoryFlowWin32]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 120
    Move-ClientCursor $Window 180 350
    Start-Sleep -Milliseconds 120
    [StoryFlowWin32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
}

function Save-ClientFrame([IntPtr]$Window, [string]$Path) {
    $bitmap = [System.Drawing.Bitmap]::new(1280, 750)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $dc = $graphics.GetHdc()
        try { $captured = [StoryFlowWin32]::PrintWindow($Window, $dc, 2) }
        finally { $graphics.ReleaseHdc($dc) }
        if (-not $captured) { throw 'PrintWindow failed' }
        $client = $bitmap.Clone([System.Drawing.Rectangle]::new(0, 30, 1280, 720), $bitmap.PixelFormat)
        try { $client.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png) }
        finally { $client.Dispose() }
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$framesDir = Join-Path $OutputDirectory 'frames'
New-Item -ItemType Directory -Force -Path $framesDir | Out-Null
$runner = Get-GamemakerRunnerExe
$process = Start-GamemakerRunnerProcess -RunnerExe $runner -GameFile $GameFile
try {
    $window = [IntPtr]::Zero
    for ($retry = 0; $retry -lt 80; $retry++) {
        Start-Sleep -Milliseconds 100
        $process.Refresh()
        if ($process.HasExited) { throw "Runner exited before window: $($process.ExitCode)" }
        $window = $process.MainWindowHandle
        if ($window -ne [IntPtr]::Zero) { break }
    }
    if ($window -eq [IntPtr]::Zero) { throw 'Runner window did not appear' }
    $target = Move-RunnerToCaptureMonitor -Window $window -Width 1280 -Height 750 -Margin 20
    Write-Output "Runner on capture monitor: $($target.X),$($target.Y) $($target.Width)x$($target.Height)"
    Start-Sleep -Milliseconds 700
    if (-not $DirectStory) {
        Save-ClientFrame $window (Join-Path $OutputDirectory 'menu.png')
        if ($CaptureSettings) {
            Click-Client $window 500 560
            Start-Sleep -Milliseconds 600
            Save-ClientFrame $window (Join-Path $OutputDirectory 'settings.png')
            Click-Client $window 640 505
            Start-Sleep -Milliseconds 600
        }
        Click-Client $window 500 490
        Start-Sleep -Milliseconds 600
        Save-ClientFrame $window (Join-Path $OutputDirectory 'mode.png')
        $modeY = if ($Mode -eq 'Story') { 140 } elseif ($Mode -eq 'Endless') { 245 } else { 350 }
        Click-Client $window 850 $modeY
        Start-Sleep -Milliseconds 200
        Click-Client $window 900 630
        Start-Sleep -Milliseconds 1000
        if ($Mode -eq 'Story') {
            Save-ClientFrame $window (Join-Path $OutputDirectory 'opening.png')
            Click-Client $window 640 600
            Start-Sleep -Milliseconds 600
        }
    }
    if ($PrepareCue) {
        Click-Client $window 380 350
        Start-Sleep -Milliseconds 400
        Move-ClientCursor $window $ShotStartX $ShotStartY
        Start-Sleep -Milliseconds 200
    }
    Save-ClientFrame $window (Join-Path $OutputDirectory 'story-initial.png')

    for ($frame = 0; $frame -lt $Frames; $frame++) {
        $process.Refresh()
        if ($process.HasExited) { throw "Runner exited during capture at frame ${frame}: $($process.ExitCode)" }
        if ($frame -eq $PlayerShotFrame) { Shoot-Player $window }
        Save-ClientFrame $window (Join-Path $framesDir ('frame_{0:D4}.png' -f $frame))
        Start-Sleep -Milliseconds 100
    }
    Copy-Item -LiteralPath (Join-Path $framesDir ('frame_{0:D4}.png' -f ($Frames - 1))) -Destination (Join-Path $OutputDirectory 'story-final.png') -Force
    if ($ResultReturn) {
        Click-Client $window $ResultReturnX $ResultReturnY
        Start-Sleep -Milliseconds 600
        Save-ClientFrame $window (Join-Path $OutputDirectory 'result-return.png')
    }
    & ffmpeg -hide_banner -loglevel error -framerate 10 -i (Join-Path $framesDir 'frame_%04d.png') -c:v libx264 -pix_fmt yuv420p -y (Join-Path $OutputDirectory 'story-flow.mp4')
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg exited with $LASTEXITCODE" }
    Write-Output "Story flow captured: frames=$Frames shotFrame=$PlayerShotFrame runnerId=$($process.Id)"
} finally {
    [StoryFlowWin32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
    if ($null -ne $process -and -not $process.HasExited) { Stop-Process -Id $process.Id -ErrorAction SilentlyContinue }
}
