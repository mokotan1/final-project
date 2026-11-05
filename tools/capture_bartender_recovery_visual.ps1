param(
    [string]$OutputDirectory = 'D:\final_project\docs\devlog\2026-10-29-bartender-recovery-on-player-loss\after\runner-visual',
    [ValidateRange(0, 2)][int]$RecoveryPhase = 2,
    [int]$Frames = 120
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')
Add-Type -AssemblyName System.Drawing

$buildOut = Join-Path $OutputDirectory 'build'
$game = & (Join-Path $PSScriptRoot 'run_bartender_recovery_capture.ps1') `
    -OutputDirectory $buildOut -RecoveryPhase $RecoveryPhase -BuildOnly
if (-not (Test-Path -LiteralPath $game)) { throw "Recovery build missing: $game" }

Assert-GamemakerRunnerLaunchEnvironment -GameFile $game
Remove-StaleRunnerDebugSidecar -GameFile $game

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$framesDir = Join-Path $OutputDirectory 'frames'
New-Item -ItemType Directory -Force -Path $framesDir | Out-Null
$logPath = Join-Path $OutputDirectory 'capture.log'

$runner = Get-GamemakerRunnerExe
$stdout = Join-Path $OutputDirectory 'runner_stdout.txt'
$stderr = Join-Path $OutputDirectory 'runner_stderr.txt'
$process = Start-GamemakerRunnerProcess -RunnerExe $runner -GameFile $game `
    -RedirectStandardOutput $stdout -RedirectStandardError $stderr

$captureMethods = @{}
try {
    $window = Wait-GamemakerRunnerGameWindow -Process $process
    $target = Move-RunnerToCaptureMonitor -Window $window -Width 1280 -Height 750 -Margin 20
    Show-RunnerCaptureWindow -Window $window
    Start-Sleep -Milliseconds 2500

    for ($frame = 0; $frame -lt $Frames; $frame++) {
        $process.Refresh()
        if ($process.HasExited) {
            throw "Runner exited during capture at frame ${frame}: $($process.ExitCode)"
        }
        $path = Join-Path $framesDir ('frame_{0:D4}.png' -f $frame)
        $method = Save-RunnerClientFrame -Window $window -OutputPath $path -CaptureMode Auto
        $captureMethods[$method] = 1 + $captureMethods[$method]
        Start-Sleep -Milliseconds 100
    }

    $initialFrame = [Math]::Min(10, $Frames - 1)
    Copy-Item -LiteralPath (Join-Path $framesDir ('frame_{0:D4}.png' -f $initialFrame)) `
        -Destination (Join-Path $OutputDirectory 'recovery-initial.png') -Force
    Copy-Item -LiteralPath (Join-Path $framesDir ('frame_{0:D4}.png' -f ($Frames - 1))) `
        -Destination (Join-Path $OutputDirectory 'recovery-final.png') -Force

    $mp4 = Join-Path $OutputDirectory 'recovery-flow.mp4'
    & ffmpeg -hide_banner -loglevel error -framerate 10 -i (Join-Path $framesDir 'frame_%04d.png') `
        -c:v libx264 -pix_fmt yuv420p -y $mp4
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg exited with $LASTEXITCODE" }

    @(
        "RecoveryPhase=$RecoveryPhase"
        "GameFile=$game"
        "CaptureMonitor=$($target.X),$($target.Y) $($target.Width)x$($target.Height)"
        "FrameMethods=$(($captureMethods.GetEnumerator() | ForEach-Object { ""$($_.Key)=$($_.Value)"" }) -join '; ')"
        "Frames=$Frames"
        "Video=$mp4"
    ) | Set-Content -LiteralPath $logPath -Encoding utf8

    Write-Output "Captured recovery visual phase=$RecoveryPhase frames=$Frames dir=$OutputDirectory"
} finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -ErrorAction SilentlyContinue
    }
}
