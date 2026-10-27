# Real Runner checks: 3 AI-break and 3 player-break sessions (injected story_test_break_breaker).
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent),
    [int]$FramesPerRun = 220,
    [int]$PlayerShotFrame = 200
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$versusCreate = Join-Path $Root 'objects/obj_story_versus_game/Create_0.gml'
$versusOriginal = [IO.File]::ReadAllBytes($versusCreate)
$logPath = Join-Path $Root 'docs/devlog/2026-10-26-story-break/after/runner-verification.log'
New-Item -ItemType Directory -Force -Path (Split-Path $logPath) | Out-Null
$log = @()

function Compile-WithBreaker([int]$Breaker) {
    $versusSource = [Text.Encoding]::UTF8.GetString($versusOriginal)
    $patched = "global.story_test_break_breaker = $Breaker;`n" + $versusSource
    [IO.File]::WriteAllText($versusCreate, $patched, [Text.UTF8Encoding]::new($false))
    & $igor "--runtimePath=$runtime" "--project=$Root\final_project.yyp" --runtime=VM `
        "--cache=$Root\Build\cache_story_break_verify" "--temp=$Root\Build\temp_story_break_verify" `
        "--of=$Root\Build\story_break_verify.win" windows Compile
    if ($LASTEXITCODE -ne 0) { throw "Igor compile failed for breaker=$Breaker" }
}

foreach ($breaker in @(1, 1, 1, 0, 0, 0)) {
    $label = if ($breaker -eq 1) { 'AI' } else { 'PLAYER' }
    Compile-WithBreaker $breaker
    $outDir = Join-Path $Root "docs/devlog/2026-10-26-story-break/after/verify-$label-$(Get-Date -Format 'HHmmss')"
    & (Join-Path $PSScriptRoot 'capture_story_flow.ps1') -GameFile (Join-Path $Root 'Build/final_project.win') `
        -OutputDirectory $outDir -Frames $FramesPerRun -PlayerShotFrame $PlayerShotFrame -DirectStory
    $log += "$(Get-Date -Format o) breaker=$label out=$outDir"
}

[IO.File]::WriteAllBytes($versusCreate, $versusOriginal)
$log | Set-Content -LiteralPath $logPath -Encoding UTF8
Write-Output "Wrote $logPath"
