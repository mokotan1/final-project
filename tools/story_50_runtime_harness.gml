// Temporary build-time harness appended to obj_story_versus_game/Create_0.gml.
// This file is not a registered GameMaker resource.
function story_test_reaction_pending(_id) {
    if (global.story_reaction_id == _id && global.story_reaction_timer > 0) return true;
    for (var _i = 0; _i < array_length(global.story_reaction_queue); _i++) {
        if (global.story_reaction_queue[_i].id == _id) return true;
    }
    return false;
}
var _failures = "";
var _case_results = "";
if (story_risk_points_for_cushions(0) != 100) _failures += "risk0 ";
if (story_risk_points_for_cushions(1) != 1000) _failures += "risk1 ";
if (story_risk_points_for_cushions(2) != 10000) _failures += "risk2 ";
if (story_risk_points_for_cushions(6) != 100000000) _failures += "risk6 ";
if (story_risk_points_for_cushions(7) != STORY_SCORE_MAX) _failures += "risk7 ";
if (story_score_add(STORY_SCORE_MAX - 1, 1) != STORY_SCORE_MAX) _failures += "scorecap ";
if (story_score_add(STORY_SCORE_MAX, 100) != STORY_SCORE_MAX) _failures += "scorecap2 ";
story_versus_init();
if (global.story_dialogue_id != "RULE-01") _failures += "rule1 ";
global.story_dialogue_timer = 0;
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "RULE-02") _failures += "rule2 ";
global.story_dialogue_timer = 0;
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "RULE-03") _failures += "rule3 ";
global.story_dialogue_timer = 0;
if (story_versus_advance_rule_dialogue()) _failures += "rule-extra ";
global.story_break_pending = false;
global.story_completed_pairs = 0;
if (story_ai_difficulty_tier() != 0) _failures += "ai-soft ";
global.story_player_score = 1500;
if (story_ai_difficulty_tier() != 1) _failures += "ai-lead ";
global.story_player_score = 0;
global.story_completed_pairs = 10;
if (story_ai_difficulty_tier() != 1) _failures += "ai-normal ";
global.story_completed_pairs = 39;
if (story_ai_difficulty_tier() != 2) _failures += "ai-allout ";
story_versus_show_gentle_dialogue();
story_versus_show_gentle_dialogue();
story_versus_show_gentle_dialogue();
if (global.story_gentle_dialogue_count != 2) _failures += "gentle-cap ";
var _placement_ball = instance_find(obj_ball_player, 0);
global.place_mode = true;
global.story_turn = STORY_TURN_PLAYER;
global.story_dialogue_timer = 60;
if (application_place_player_ball(_placement_ball, 400, 400) || !global.place_mode)
    _failures += "place-lock ";
global.place_mode = false;
global.story_dialogue_timer = 0;

for (var _case = 0; _case < 5; _case++) {
    global.story_test_max_turns = (_case == 4) ? 5 : 0;
    global.story_test_break_breaker = STORY_TURN_AI;
    story_versus_init();
    global.story_break_assign_dialogue_pending = false;
    global.story_dialogue_timer = 0;
    var _max_pairs = story_versus_max_turns();
    if (global.story_completed_pairs != 0 || global.story_player_score != 0 || global.story_ai_score != 0)
        _failures += "fresh" + string(_case) + " ";

    if (_case == 3) {
        story_versus_pass_turn_no_shot("BREAK PASS");
        if (global.story_completed_pairs != 0 || global.story_turn != STORY_TURN_PLAYER)
            _failures += "breakpass ";
    } else {
        global.shot_active = true;
        global.shot_scored = true;
        global.shot_pending_points = 100;
        global.story_shot_is_break = true;
        story_versus_on_shot_ended();
        if (global.story_completed_pairs != 0 || global.story_ai_score != 100
            || global.story_turn != STORY_TURN_PLAYER) _failures += "break" + string(_case) + " ";
    }

    if (_case == 0) global.story_player_score = 400;
    if (_case == 1) global.story_ai_score = 900;
    if (_case == 2) { global.story_player_score = 100; global.story_ai_score = 100; }

    for (var _pair = 1; _pair <= _max_pairs; _pair++) {
        global.shot_active = true;
        global.shot_scored = false;
        global.shot_penalized = false;
        global.shot_pending_points = 0;
        story_versus_on_shot_ended();
        if (global.story_completed_pairs != _pair - 1 || global.story_match_over
            || global.story_turn != STORY_TURN_AI)
            _failures += "player" + string(_case) + "-" + string(_pair) + " ";

        if (_case == 3 && _pair == 1) story_versus_pass_turn_no_shot("AI PASS");
        else {
            if (_case == 4 && _pair == 1) global.story_ai_shot_was_gentle = true;
            global.shot_active = true;
            global.shot_scored = false;
            global.shot_penalized = false;
            global.shot_pending_points = 0;
            story_versus_on_shot_ended();
            if (_case == 4 && _pair == 1 && (!story_test_reaction_pending("GENTLE")
                || global.story_gentle_dialogue_count != 1))
                _failures += "gentle-display ";
        }
        if (global.story_completed_pairs != _pair) _failures += "pair" + string(_case) + "-" + string(_pair) + " ";
        if (_case == 0 && _pair == 24 && !story_test_reaction_pending("TURN-25")) _failures += "turn25 ";
        if (_case == 0 && _pair == 39 && !story_test_reaction_pending("TURN-40")) _failures += "turn40 ";
        if (_case == 0 && _pair == 49 && !story_test_reaction_pending("TURN-50")) _failures += "turn50 ";
        if (_pair < _max_pairs && (global.story_match_over || global.story_turn != STORY_TURN_PLAYER))
            _failures += "early" + string(_case) + "-" + string(_pair) + " ";
    }
    var _expected_winner = (_case == 0) ? STORY_TURN_PLAYER
        : ((_case == 1 || _case == 4) ? STORY_TURN_AI : -1);
    if (!global.story_match_over || global.story_winner != _expected_winner
        || story_versus_current_round_number() != _max_pairs)
        _failures += "result" + string(_case) + "(" + string(global.story_match_over)
            + "," + string(global.story_winner) + "," + string(story_versus_current_round_number())
            + "," + string(_max_pairs) + ") ";
    if (global.story_result_completed_pairs != _max_pairs
        || global.story_result_player_score != global.story_player_score
        || global.story_result_ai_score != global.story_ai_score
        || global.story_result_score_diff != global.story_player_score - global.story_ai_score)
        _failures += "result-data" + string(_case) + " ";
    var _expected_id = (_case == 0) ? "RESULT-WIN"
        : ((_case == 1 || _case == 4) ? "RESULT-LOSE" : "RESULT-DRAW");
    if (global.story_result_dialogue_id != _expected_id
        || global.story_dialogue_id != _expected_id)
        _failures += "result-id" + string(_case) + " ";
    _case_results += "case" + string(_case) + "(pairs=" + string(global.story_completed_pairs)
        + ",winner=" + string(global.story_winner) + ",id=" + global.story_result_dialogue_id + ");";
}

var _result = (_failures == "")
    ? ("PASS " + _case_results + " checks=rule1/2/3,turn25/40/50,risk0/1/2/6/7,scorecap,ai-tiers,gentle-cap,gentle-display,place-lock,break,break-pass,ai-pass,result-data")
    : ("FAIL " + _failures + " " + _case_results);
var _file = file_text_open_write("story50_runtime_test.txt");
file_text_write_string(_file, _result);
file_text_close(_file);
show_debug_message("STORY50_RUNTIME_TEST " + _result);
game_end();
