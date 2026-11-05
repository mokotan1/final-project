param(
    [string]$OutputDirectory = 'D:\final_project\docs\devlog\2026-11-03-unity-live-gm-parity\after\gm-runner-trace',
    [string]$GameFile = 'D:\final_project\Build\physics_live_trace_test.win',
    [switch]$SkipBuild,
    [switch]$SkipEnvironmentCheck
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$stdout = Join-Path $OutputDirectory 'runner_stdout.txt'
$stderr = Join-Path $OutputDirectory 'runner_stderr.txt'
$jsonOut = Join-Path $OutputDirectory 'gm_live_physics_312_15_runner.json'

if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot 'build_physics_live_trace.ps1') -OutputWin $GameFile | Out-Null
}
if (-not (Test-Path -LiteralPath $GameFile)) {
    throw "Missing game package: $GameFile"
}

Assert-GamemakerRunnerLaunchEnvironment -GameFile $GameFile -SkipCheck:$SkipEnvironmentCheck
Remove-StaleRunnerDebugSidecar -GameFile $GameFile

$runner = Get-GamemakerRunnerExe
$process = Start-GamemakerRunnerProcess -RunnerExe $runner -GameFile $GameFile `
    -RedirectStandardOutput $stdout -RedirectStandardError $stderr
$process.WaitForExit()
if ($process.ExitCode -ne 0) {
    throw "Runner exit code $($process.ExitCode). See $stdout and $stderr"
}

& python (Join-Path $PSScriptRoot 'parse_physics_live_trace_stdout.py') `
    --stdout $stdout --output $jsonOut

Write-Output $jsonOut
