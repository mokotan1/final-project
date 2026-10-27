param(
    [string]$GameFile,
    [switch]$SkipProbe,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')

$runner = Get-GamemakerRunnerExe
$probeGame = if ($GameFile) { $GameFile } else { Get-RunnerProbeGameFile -PreferredGameFile $null }

$summary = [ordered]@{
    Timestamp = (Get-Date).ToString('o')
    Host = $env:COMPUTERNAME
    User = $env:USERNAME
    Process = 'powershell'
    ProcessId = $PID
    RunnerExe = $runner
    ProbeGameFile = $probeGame
    ProbeSkipped = [bool]$SkipProbe
    Launch = $null
}

if (-not $SkipProbe) {
    $summary.Launch = Test-GamemakerRunnerLaunch -RunnerExe $runner -GameFile $probeGame
}

if ($Json) {
    $summary | ConvertTo-Json -Depth 5
} else {
    Write-Output "Runner: $($summary.RunnerExe)"
    Write-Output "Probe game: $($summary.ProbeGameFile)"
    if ($SkipProbe) {
        Write-Output 'Probe: skipped'
        exit 0
    }
    $launch = $summary.Launch
    Write-Output "CanLaunch: $($launch.CanLaunch)"
    if ($launch.MainWindowHandle) { Write-Output "MainWindowHandle: $($launch.MainWindowHandle)" }
    if ($launch.NativeErrorCode) { Write-Output "NativeErrorCode: $($launch.NativeErrorCode)" }
    if ($launch.ErrorMessage) { Write-Output "Error: $($launch.ErrorMessage)" }
    Write-Output "RestrictedEnvironmentLikely: $($launch.RestrictedEnvironmentLikely)"
}

if ($SkipProbe) { exit 0 }
if ($summary.Launch.CanLaunch) { exit 0 }
exit 2
