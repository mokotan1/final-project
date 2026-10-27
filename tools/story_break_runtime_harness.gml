// Temporary build-time harness (injected label: STORY_BREAK_RUNTIME_TEST).
var _failures = "";
global.story_test_break_breaker = STORY_TURN_PLAYER;
story_versus_init();
global.story_break_assign_dialogue_pending = false;
global.story_dialogue_timer = 0;
if (global.story_break_breaker != STORY_TURN_AI || global.story_turn != STORY_TURN_AI
    || !global.story_break_pending) _failures += "bartender-breaker-init ";
global.shot_active = true;
global.story_turn = STORY_TURN_AI;
global.story_shot_is_break = true;
global.shot_scored = true;
global.shot_pending_points = 100;
story_versus_on_shot_ended();
if (global.story_completed_pairs != 0 || global.story_ai_score != 100
    || global.story_turn != STORY_TURN_PLAYER) _failures += "ai-break-end ";

global.shot_active = true;
global.story_shot_is_break = true;
if (!story_versus_break_foul_rules_suppressed()) _failures += "break-foul-flag ";
global.shot_penalized = false;
if (story_versus_on_foul_hit(noone, noone) || global.shot_penalized) _failures += "break-foul-suppress ";

for (var _case = 0; _case < 10; _case++) {
    story_versus_init();
    if (global.story_break_breaker != STORY_TURN_AI || global.story_turn != STORY_TURN_AI)
        _failures += "bartender-only-" + string(_case) + " ";
    global.story_dialogue_timer = 0;
    global.shot_active = true;
    global.story_shot_is_break = true;
    story_versus_on_shot_ended();
    if (global.story_completed_pairs != 0 || global.story_turn != STORY_TURN_PLAYER)
        _failures += "bartender-handoff-" + string(_case) + " ";
}

story_versus_init();
story_versus_spawn_layout();
global.story_dialogue_timer = 0;
global.story_reaction_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
if (!story_ai_execute_turn()) _failures += "bartender-shot-failed ";
var _break_ball = instance_find(obj_ball_ai, 0);
if (!instance_exists(_break_ball)) _failures += "bartender-ball-missing ";
else {
    var _actual_power = point_distance(0, 0, _break_ball.hspeed, _break_ball.vspeed);
    if (_actual_power < 26 || _actual_power > 30) _failures += "bartender-break-power ";
}

var _result = (_failures == "")
    ? "PASS bartender-break-10,0-pair-handoff,break-foul-suppress,power-26-30 (player override ignored)"
    : ("FAIL " + _failures);
var _file = file_text_open_write("story_break_runtime_test.txt");
file_text_write_string(_file, _result);
file_text_close(_file);
show_debug_message("STORY_BREAK_RUNTIME_TEST " + _result);
game_end();
