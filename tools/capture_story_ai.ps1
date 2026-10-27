param(
    [string]$GameFile = 'D:\final_project\Build\verify_project.win',
    [string]$OutputDirectory = 'D:\final_project\docs\devlog\2026-10-15-story-ai-runtime-check\after',
    [switch]$SkipEnvironmentCheck
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')
Assert-GamemakerRunnerLaunchEnvironment -GameFile $GameFile -SkipCheck:$SkipEnvironmentCheck

Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class StoryCaptureWin32 {
    [StructLayout(LayoutKind.Sequential)] public struct Point { public int X; public int Y; }
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr window, IntPtr dc, uint flags);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr window, ref Point point);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr window);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
}
'@

$runner = Get-GamemakerRunnerExe
$frames = Join-Path $OutputDirectory 'frames'
New-Item -ItemType Directory -Force -Path $frames | Out-Null
$gameProcess = Start-GamemakerRunnerProcess -RunnerExe $runner -GameFile $GameFile `
    -RedirectStandardOutput (Join-Path $OutputDirectory 'runner_stdout.txt') `
    -RedirectStandardError (Join-Path $OutputDirectory 'runner_stderr.txt')
try {
    $window = [IntPtr]::Zero
    for ($retry = 0; $retry -lt 40; $retry++) {
        Start-Sleep -Milliseconds 100
        $gameProcess.Refresh()
        if ($gameProcess.HasExited) { throw "Runner exited early: $($gameProcess.ExitCode)" }
        $window = $gameProcess.MainWindowHandle
        if ($window -ne [IntPtr]::Zero) { break }
    }
    if ($window -eq [IntPtr]::Zero) { throw 'Runner window did not appear' }

    $shotSent = $false
    for ($frame = 0; $frame -lt 300; $frame++) {
        $gameProcess.Refresh()
        if ($gameProcess.HasExited) { throw "Runner exited during capture: $($gameProcess.ExitCode)" }

        if ($frame -eq 15) {
            [StoryCaptureWin32]::SetForegroundWindow($window) | Out-Null
            $start = [StoryCaptureWin32+Point]::new()
            $start.X = 380; $start.Y = 350
            [StoryCaptureWin32]::ClientToScreen($window, [ref]$start) | Out-Null
            [StoryCaptureWin32]::SetCursorPos($start.X, $start.Y) | Out-Null
            Start-Sleep -Milliseconds 120
            [StoryCaptureWin32]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
            Start-Sleep -Milliseconds 120
            $end = [StoryCaptureWin32+Point]::new()
            $end.X = 180; $end.Y = 350
            [StoryCaptureWin32]::ClientToScreen($window, [ref]$end) | Out-Null
            [StoryCaptureWin32]::SetCursorPos($end.X, $end.Y) | Out-Null
            Start-Sleep -Milliseconds 120
            [StoryCaptureWin32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
            $shotSent = $true
        }

        $bitmap = [System.Drawing.Bitmap]::new(1280, 720)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $dc = $graphics.GetHdc()
        $captured = [StoryCaptureWin32]::PrintWindow($window, $dc, 2)
        $graphics.ReleaseHdc($dc)
        $graphics.Dispose()
        if (-not $captured) { $bitmap.Dispose(); throw 'PrintWindow failed' }
        $path = Join-Path $frames ('frame_{0:D4}.png' -f $frame)
        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        Start-Sleep -Milliseconds 100
    }
    Copy-Item -LiteralPath (Join-Path $frames 'frame_0000.png') -Destination (Join-Path $OutputDirectory 'initial.png') -Force
    Copy-Item -LiteralPath (Join-Path $frames 'frame_0299.png') -Destination (Join-Path $OutputDirectory 'final.png') -Force
    & ffmpeg -hide_banner -loglevel error -framerate 10 -i (Join-Path $frames 'frame_%04d.png') -c:v libx264 -pix_fmt yuv420p -y (Join-Path $OutputDirectory 'player-ai-turn.mp4')
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg exited with $LASTEXITCODE" }
    Write-Output "ShotSent=$shotSent RunnerId=$($gameProcess.Id) Frames=300"
} finally {
    [StoryCaptureWin32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
    if (-not $gameProcess.HasExited) { Stop-Process -Id $gameProcess.Id -ErrorAction SilentlyContinue }
}
