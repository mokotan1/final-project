param(
    [Parameter(Mandatory)][string]$OutputDirectory,
    [int]$Frames = 240
)

# Does not start Runner.exe. Launch the game from the desktop (IDE or Runner -game)
# then run this script in the same session. See tools/RUNNER_CAPTURE.md.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ExistingRunnerCapture {
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr window, IntPtr dc, uint flags);
}
'@

$runner = Get-Process -Name Runner -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
    Sort-Object StartTime -Descending |
    Select-Object -First 1
if ($null -eq $runner) { throw 'No open Runner game window was found.' }

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$frameDirectory = Join-Path $OutputDirectory 'frames'
New-Item -ItemType Directory -Force -Path $frameDirectory | Out-Null
$window = $runner.MainWindowHandle

for ($frame = 0; $frame -lt $Frames; $frame++) {
    $runner.Refresh()
    if ($runner.HasExited) { throw "Runner exited during capture at frame $frame" }
    $bitmap = [System.Drawing.Bitmap]::new(1280, 720)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $dc = $graphics.GetHdc()
    $captured = [ExistingRunnerCapture]::PrintWindow($window, $dc, 2)
    $graphics.ReleaseHdc($dc)
    $graphics.Dispose()
    if (-not $captured) { $bitmap.Dispose(); throw "PrintWindow failed at frame $frame" }
    $bitmap.Save((Join-Path $frameDirectory ('frame_{0:D4}.png' -f $frame)), [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    Start-Sleep -Milliseconds 100
}

Copy-Item -LiteralPath (Join-Path $frameDirectory 'frame_0000.png') -Destination (Join-Path $OutputDirectory 'initial.png') -Force
Copy-Item -LiteralPath (Join-Path $frameDirectory ('frame_{0:D4}.png' -f ($Frames - 1))) -Destination (Join-Path $OutputDirectory 'final.png') -Force
& ffmpeg -hide_banner -loglevel error -framerate 10 -i (Join-Path $frameDirectory 'frame_%04d.png') -c:v libx264 -pix_fmt yuv420p -y (Join-Path $OutputDirectory 'story-break.mp4')
if ($LASTEXITCODE -ne 0) { throw "ffmpeg exited with $LASTEXITCODE" }
Write-Output "Captured $Frames frames from Runner $($runner.Id)"
