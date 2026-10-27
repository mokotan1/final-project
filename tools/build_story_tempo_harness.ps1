$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$createFile = Join-Path $root 'objects/obj_story_versus_game/Create_0.gml'
$introFile = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$original = [IO.File]::ReadAllBytes($createFile)
$introOriginal = [IO.File]::ReadAllBytes($introFile)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
try {
    $source = [Text.Encoding]::UTF8.GetString($original)
    $harness = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'story_turn_tempo_harness.gml'), [Text.Encoding]::UTF8)
    [IO.File]::WriteAllText($createFile, $source + "`n" + $harness, [Text.UTF8Encoding]::new($false))
    $intro = [Text.Encoding]::UTF8.GetString($introOriginal)
    $intro = $intro.Replace('audio_volume_init();', "audio_volume_init();`nglobal.story_intro_match = true;`nroom_goto(rm_story_ai_verify);`nexit;")
    [IO.File]::WriteAllText($introFile, $intro, [Text.UTF8Encoding]::new($false))
    $log = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_story_tempo_harness" "--temp=$root\Build\temp_story_tempo_harness" `
        "--of=$root\Build\story_turn_tempo_test.win" windows Compile
    if ($LASTEXITCODE -ne 0) { $log | Select-Object -Last 30; throw "Igor failed: $LASTEXITCODE" }
    $iff = @($log | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'Igor did not report output path' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination (Join-Path $root 'Build/story_turn_tempo_test.win') -Force
} finally {
    [IO.File]::WriteAllBytes($createFile, $original)
    [IO.File]::WriteAllBytes($introFile, $introOriginal)
}
