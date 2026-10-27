param(
    [Parameter(Mandatory)][string]$GameFile,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [switch]$SkipEnvironmentCheck
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')
Assert-GamemakerRunnerLaunchEnvironment -GameFile $GameFile -SkipCheck:$SkipEnvironmentCheck

Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class StartupCaptureWin32 {
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr window, IntPtr dc, uint flags);
}
'@

$runner = Get-GamemakerRunnerExe
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$frames = Join-Path $OutputDirectory 'frames'
New-Item -ItemType Directory -Force -Path $frames | Out-Null
$process = Start-GamemakerRunnerProcess -RunnerExe $runner -GameFile $GameFile
try {
    $window = [IntPtr]::Zero
    for ($retry = 0; $retry -lt 40; $retry++) {
        Start-Sleep -Milliseconds 100
        $process.Refresh()
        if ($process.HasExited) { throw "Runner exited early: $($process.ExitCode)" }
        $window = $process.MainWindowHandle
        if ($window -ne [IntPtr]::Zero) { break }
    }
    if ($window -eq [IntPtr]::Zero) { throw 'Runner window did not appear' }
    for ($frame = 0; $frame -lt 50; $frame++) {
        $bitmap = [System.Drawing.Bitmap]::new(1280, 720)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $dc = $graphics.GetHdc()
        $captured = [StartupCaptureWin32]::PrintWindow($window, $dc, 2)
        $graphics.ReleaseHdc($dc)
        $graphics.Dispose()
        if (-not $captured) { $bitmap.Dispose(); throw 'PrintWindow failed' }
        $bitmap.Save((Join-Path $frames ('frame_{0:D4}.png' -f $frame)), [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        Start-Sleep -Milliseconds 100
    }
    Copy-Item -LiteralPath (Join-Path $frames 'frame_0010.png') -Destination (Join-Path $OutputDirectory 'initial.png') -Force
    & ffmpeg -hide_banner -loglevel error -framerate 10 -i (Join-Path $frames 'frame_%04d.png') -c:v libx264 -pix_fmt yuv420p -y (Join-Path $OutputDirectory 'startup.mp4')
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg exited with $LASTEXITCODE" }
    Write-Output "Captured 50 frames from Runner $($process.Id)"
} finally {
    if (-not $process.HasExited) { Stop-Process -Id $process.Id -ErrorAction SilentlyContinue }
}
