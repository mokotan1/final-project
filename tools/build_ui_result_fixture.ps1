param([string]$Output = 'D:\final_project\Build\2026-10-26-ui-result-fixture.win')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$introPath = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$gamePath = Join-Path $root 'objects/obj_game/Create_0.gml'
$introBytes = [IO.File]::ReadAllBytes($introPath)
$gameBytes = [IO.File]::ReadAllBytes($gamePath)
$utf8 = [Text.UTF8Encoding]::new($false)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
try {
    $intro = [Text.Encoding]::UTF8.GetString($introBytes)
    $intro = $intro.Replace('audio_volume_init();', "audio_volume_init();`nglobal.game_mode = GAME_MODE_ENDLESS;`nroom_goto(rm_game);`nexit;")
    [IO.File]::WriteAllText($introPath, $intro, $utf8)
    $game = [Text.Encoding]::UTF8.GetString($gameBytes)
    $game += "`n// UI-only result fixture: no shot, no score save.`nglobal.score = 1005370;`nglobal.best_score = 1005370;`nglobal.game_over = true;`nglobal.game_over_delay = 0;`n"
    [IO.File]::WriteAllText($gamePath, $game, $utf8)
    $buildLog = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_ui_result_fixture_20261026" `
        "--temp=$root\Build\temp_ui_result_fixture_20261026" windows Compile
    if ($LASTEXITCODE -ne 0) { throw "Igor exited $LASTEXITCODE" }
    $iff = @($buildLog | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'Igor did not report an IFF output path' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination $Output -Force
} finally {
    [IO.File]::WriteAllBytes($introPath, $introBytes)
    [IO.File]::WriteAllBytes($gamePath, $gameBytes)
}
