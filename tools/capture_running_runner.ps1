param([Parameter(Mandatory)][int]$RunnerId, [Parameter(Mandatory)][string]$OutputPath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class RunningRunnerWindow {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr window);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr window, IntPtr dc, uint flags);
}
'@
$runner = Get-Process -Id $RunnerId -ErrorAction Stop
$runner.Refresh()
$window = $runner.MainWindowHandle
if ($window -eq [IntPtr]::Zero) { throw 'Runner window handle unavailable' }
[RunningRunnerWindow]::SetForegroundWindow($window) | Out-Null
Start-Sleep -Milliseconds 150
$whole = [System.Drawing.Bitmap]::new(1280, 750)
$graphics = [System.Drawing.Graphics]::FromImage($whole)
try {
    $dc = $graphics.GetHdc()
    try { $ok = [RunningRunnerWindow]::PrintWindow($window, $dc, 2) }
    finally { $graphics.ReleaseHdc($dc) }
    if (-not $ok) { throw 'PrintWindow failed' }
    $client = $whole.Clone([System.Drawing.Rectangle]::new(0, 30, 1280, 720), $whole.PixelFormat)
    try { $client.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png) }
    finally { $client.Dispose() }
} finally {
    $graphics.Dispose()
    $whole.Dispose()
}
