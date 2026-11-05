param([string]$OutputDirectory = 'D:\final_project\docs\devlog\2026-10-29-bartender-item-playcheck')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$intro = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$create = Join-Path $root 'objects/obj_story_versus_game/Create_0.gml'
$step = Join-Path $root 'objects/obj_story_versus_game/Step_0.gml'
$ai = Join-Path $root 'scripts/scr_story_ai/scr_story_ai.gml'
$paths = @($intro, $create, $step, $ai)
$original = @{}
foreach ($path in $paths) { $original[$path] = [IO.File]::ReadAllBytes($path) }
$utf8 = [Text.UTF8Encoding]::new($false)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$runner = Join-Path $runtime 'windows\x64\Runner.exe'
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$game = Join-Path $OutputDirectory 'bartender_item_playcheck.win'
try {
    $introSource = [Text.Encoding]::UTF8.GetString($original[$intro]).Replace('audio_volume_init();', "audio_volume_init();`nglobal.story_intro_match = true;`nroom_goto(rm_story_ai_verify);`nexit;")
    [IO.File]::WriteAllText($intro, $introSource, $utf8)
    $fixture = @'
if (!variable_global_exists("bartender_check_case")) global.bartender_check_case = 0;
global.story_break_pending = false;
global.story_shot_is_break = false;
global.story_completed_pairs = 15;
global.story_turn = STORY_TURN_AI;
global.story_rule_dialogue_index = 2;
global.story_dialogue_timer = 0;
global.story_reaction_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_ai_recovery_due_pair = -1;
global.story_ai_score = (global.bartender_check_case == 2) ? 4000 : 2000;
global.story_player_score = (global.bartender_check_case == 2) ? 104000 : 0;
application_destroy_all_balls();
story_versus_spawn_ball_at("obj_ball_player", 380, 350);
story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
story_versus_spawn_ball_at("obj_ball_target", 640, 260);
if (global.bartender_check_case == 1)
    story_versus_spawn_ball_at("obj_ball_foul", 760, 350);
else
    story_versus_spawn_ball_at("obj_ball_foul", 500, 300);
global.bartender_check_started = false;
show_debug_message("ITEM_PLAY_START case=" + string(global.bartender_check_case)
    + " ai=" + string(global.story_ai_score) + " player=" + string(global.story_player_score)
    + " fouls=" + string(instance_number(obj_ball_foul)));
'@
    [IO.File]::WriteAllText($create, [Text.Encoding]::UTF8.GetString($original[$create]) + "`n" + $fixture, $utf8)
    $stepPrefix = @'
if (global.story_turn == STORY_TURN_AI && (global.shot_active || global.story_item_used_this_turn))
    global.bartender_check_started = true;
if (global.bartender_check_started && global.story_turn == STORY_TURN_PLAYER && !global.shot_active) {
    show_debug_message("ITEM_PLAY_END case=" + string(global.bartender_check_case)
        + " items=" + string(global.story_ai_item_use_counts[0]) + ","
        + string(global.story_ai_item_use_counts[1]) + "," + string(global.story_ai_item_use_counts[2])
        + " ai=" + string(global.story_ai_score) + " player=" + string(global.story_player_score)
        + " fouls=" + string(instance_number(obj_ball_foul))
        + " removed_pending=" + string(array_length(global.story_removed_foul_balls))
        + " risk_armed=" + string(global.story_ai_risk_shot_armed)
        + " item_used=" + string(global.story_item_used_this_turn)
        + " pairs=" + string(global.story_completed_pairs));
    global.bartender_check_case += 1;
    if (global.bartender_check_case < 3) room_restart(); else game_end();
    exit;
}
'@
    [IO.File]::WriteAllText($step, $stepPrefix + "`n" + [Text.Encoding]::UTF8.GetString($original[$step]), $utf8)
    $aiSource = [Text.Encoding]::UTF8.GetString($original[$ai])
    $needle = 'function story_ai_pick_shot() {'
    $replacement = @'
function story_ai_pick_shot() {
    if (variable_global_exists("bartender_check_case"))
        return { direction: (global.bartender_check_case == 1) ? 180 : 0,
            power: 12, cushions: 2,
            expected_score: (global.bartender_check_case == 1) ? 0 : 1600 };
'@
    if (-not $aiSource.Contains($needle)) { throw 'AI hook not found' }
    [IO.File]::WriteAllText($ai, $aiSource.Replace($needle, $replacement), $utf8)
    $buildLog = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_bartender_item_playcheck" "--temp=$root\Build\temp_bartender_item_playcheck" `
        "--of=$game" windows Compile
    $buildLog | Set-Content -LiteralPath (Join-Path $OutputDirectory 'compile.log')
    if ($LASTEXITCODE -ne 0) { throw "Igor failed: $LASTEXITCODE" }
    $iff = @($buildLog | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'IFF output path missing' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination $game -Force
} finally {
    foreach ($path in $paths) { [IO.File]::WriteAllBytes($path, $original[$path]) }
}
Write-Output $game
