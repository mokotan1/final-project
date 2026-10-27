param([Parameter(Mandatory)][ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$introFile = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$uiCreateFile = Join-Path $root 'objects/obj_ui/Create_0.gml'
$uiStepFile = Join-Path $root 'objects/obj_ui/Step_0.gml'
$intro = [IO.File]::ReadAllBytes($introFile)
$uiCreate = [IO.File]::ReadAllBytes($uiCreateFile)
$uiStep = [IO.File]::ReadAllBytes($uiStepFile)
$utf8 = [Text.UTF8Encoding]::new($false)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
try {
    $introSource = [Text.Encoding]::UTF8.GetString($intro)
    $introSource = $introSource.Replace('audio_volume_init();', "audio_volume_init();`nglobal.game_mode = GAME_MODE_ENDLESS;`nroom_goto(rm_game);`nexit;")
    [IO.File]::WriteAllText($introFile, $introSource, $utf8)
    [IO.File]::WriteAllText($uiCreateFile, [Text.Encoding]::UTF8.GetString($uiCreate) + "`nrisk_cap_fixture_frame = 0;`n", $utf8)
    $fixture = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'endless_score_cap_harness.gml'), [Text.Encoding]::UTF8)
    [IO.File]::WriteAllText($uiStepFile, $fixture + "`n" + [Text.Encoding]::UTF8.GetString($uiStep), $utf8)
    & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_endless_cap_$Phase" "--temp=$root\Build\temp_endless_cap_$Phase" `
        "--of=$root\Build\endless_cap_$Phase.win" windows Compile
    if ($LASTEXITCODE -ne 0) { throw "Igor failed with exit code $LASTEXITCODE" }
    Copy-Item -LiteralPath (Join-Path $root 'Build/final_project.win') -Destination (Join-Path $root "Build/endless_cap_$Phase.win") -Force
} finally {
    [IO.File]::WriteAllBytes($introFile, $intro)
    [IO.File]::WriteAllBytes($uiCreateFile, $uiCreate)
    [IO.File]::WriteAllBytes($uiStepFile, $uiStep)
}
