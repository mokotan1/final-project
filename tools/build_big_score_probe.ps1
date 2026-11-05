param([Parameter(Mandatory)][string]$Output)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$introPath = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$storyPath = Join-Path $root 'objects/obj_story_versus_game/Create_0.gml'
$fontPath = Join-Path $root 'scripts/scr_ui_pixel_text/scr_ui_pixel_text.gml'
$drawPath = Join-Path $root 'objects/obj_ui/Draw_64.gml'
$paths = @($introPath, $storyPath, $fontPath, $drawPath)
$original = @{}
foreach ($path in $paths) { $original[$path] = [IO.File]::ReadAllBytes($path) }
$utf8 = [Text.UTF8Encoding]::new($false)
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$igor = Join-Path $runtime 'bin\igor\windows\x64\Igor.exe'
try {
    $intro = [Text.Encoding]::UTF8.GetString($original[$introPath])
    $intro = $intro.Replace('audio_volume_init();', "audio_volume_init();`nglobal.story_intro_match = true;`nroom_goto(rm_story_ai_verify);`nexit;")
    [IO.File]::WriteAllText($introPath, $intro, $utf8)

    $story = [Text.Encoding]::UTF8.GetString($original[$storyPath])
    $story += "`nglobal.story_break_pending = false;`nglobal.story_dialogue_timer = 0;`nglobal.score_gain_fx = { active: true, from: 0, gain: 100000, age: 0, life: 240 };`n"
    [IO.File]::WriteAllText($storyPath, $story, $utf8)

    $font = [Text.Encoding]::UTF8.GetString($original[$fontPath])
    $needle = 'var _font = font_add(_file, _px, false, false, 32, 126);'
    if (-not $font.Contains($needle)) { throw 'font_add probe point not found' }
    $font = $font.Replace($needle, "var _font_start_us = get_timer();`n        $needle`n        show_debug_message(`"BIG_SCORE_FONT px=`" + string(_px) + `" ms=`" + string((get_timer() - _font_start_us) / 1000));")
    [IO.File]::WriteAllText($fontPath, $font, $utf8)

    $draw = [Text.Encoding]::UTF8.GetString($original[$drawPath])
    $prefix = @'
if (variable_global_exists("big_score_probe_last_us") && global.score_gain_fx.active && global.score_gain_fx.age <= 35)
    show_debug_message("BIG_SCORE_FRAME age=" + string(global.score_gain_fx.age)
        + " ms=" + string((get_timer() - global.big_score_probe_last_us) / 1000));
global.big_score_probe_last_us = get_timer();
'@
    [IO.File]::WriteAllText($drawPath, $prefix + "`n" + $draw, $utf8)

    $log = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_big_score_probe" "--temp=$root\Build\temp_big_score_probe" `
        "--of=$Output" windows Compile
    if ($LASTEXITCODE -ne 0) { $log | Select-Object -Last 40; throw "Igor failed: $LASTEXITCODE" }
    $iff = @($log | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'Igor did not report output path' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination $Output -Force
    Write-Output "Built $Output"
} finally {
    foreach ($path in $paths) {
        for ($attempt = 0; $attempt -lt 20; $attempt++) {
            try {
                [IO.File]::WriteAllBytes($path, $original[$path])
                break
            } catch [IO.IOException] {
                if ($attempt -eq 19) { throw }
                Start-Sleep -Milliseconds 250
            }
        }
    }
}
