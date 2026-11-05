// Temporary build-time harness appended to obj_story_versus_game/Create_0.gml.
// This file is not a registered GameMaker resource.
function story_test_reaction_pending(_id) {
    if (global.story_reaction_id == _id && global.story_reaction_timer > 0) return true;
    for (var _i = 0; _i < array_length(global.story_reaction_queue); _i++) {
        if (global.story_reaction_queue[_i].id == _id) return true;
    }
    return false;
}
function story_test_foul_at(_x, _y) {
    with (obj_ball_foul) {
        if (abs(x - _x) < 0.1 && abs(y - _y) < 0.1) return true;
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
if (story_versus_item_price(1, STORY_TURN_PLAYER) != 200
    || story_versus_item_price(2, STORY_TURN_PLAYER) != 800
    || story_versus_item_price(3, STORY_TURN_PLAYER) != 400
    || story_versus_item_price(1, STORY_TURN_AI) != 800
    || story_versus_item_price(2, STORY_TURN_AI) != 3200
    || story_versus_item_price(3, STORY_TURN_AI) != 1600)
    _failures += "side-prices ";
story_versus_init();
if (global.story_dialogue_id != "RULE-01") _failures += "rule1 ";
if (story_versus_skip_dialogue() || global.story_dialogue_timer <= 0)
    _failures += "rule-skip-lock ";
global.story_dialogue_timer = 0;
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "RULE-02") _failures += "rule2 ";
global.story_dialogue_timer = 0;
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "RULE-03") _failures += "rule3 ";
global.story_dialogue_timer = 0;
if (story_versus_advance_rule_dialogue()) _failures += "rule-extra ";
global.story_break_pending = false;
global.story_dialogue_timer = 0;
global.story_reaction_timer = 0;
story_versus_queue_reaction("TEST-SHORT", "짧은 대사", room_speed * 6);
if (global.story_reaction_timer != room_speed * 2)
    _failures += "reaction-reading-time ";
if (!story_versus_skip_dialogue() || global.story_reaction_timer != 0)
    _failures += "reaction-skip ";
global.story_completed_pairs = 0;
if (story_ai_difficulty_tier() != 0) _failures += "ai-soft ";
global.story_player_score = 1999;
if (story_ai_difficulty_tier() != 0) _failures += "ai-soft-edge ";
global.story_player_score = 2000;
if (story_ai_difficulty_tier() != 1) _failures += "ai-catchup-tier ";
global.story_player_score = 9600;
if (story_ai_difficulty_tier() != 2) _failures += "ai-lead ";
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

// Recovery risk: only a player score loss while the bartender leads by 100k+ can schedule it, once.
story_versus_init();
global.story_break_pending = false;
global.story_completed_pairs = 15;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn = STORY_TURN_AI;
global.story_player_score = 120000;
global.story_ai_score = 230000;
with (obj_ball_foul) instance_destroy();
for (var _attempt = 0; _attempt < 100; _attempt++) {
    story_ai_consider_items({ expected_score: 1600, direction: 0 });
}
if (global.story_ai_recovery_due_pair >= 0)
    _failures += "recovery-without-player-loss ";
global.story_player_score = 45000;
global.story_ai_score = 160000;
var _player_before_loss = global.story_player_score;
global.story_player_score = 0;
story_versus_try_schedule_ai_recovery_risk(_player_before_loss);
if (global.story_ai_recovery_due_pair < 0)
    _failures += "recovery-below-threshold ";
global.story_player_score = 0;
global.story_ai_score = 99999;
global.story_ai_recovery_due_pair = -1;
story_versus_try_schedule_ai_recovery_risk(50000);
if (global.story_ai_recovery_due_pair >= 0)
    _failures += "recovery-below-threshold ";
global.story_ai_score = 100000;
story_versus_try_schedule_ai_recovery_risk(50000);
var _recovery_due_pair = global.story_ai_recovery_due_pair;
if (_recovery_due_pair < 16 || _recovery_due_pair > 25)
    _failures += "recovery-window ";
if (_recovery_due_pair > 16 && global.story_ai_risk_shot_armed)
    _failures += "recovery-early ";
global.story_completed_pairs = _recovery_due_pair - 1;
application_destroy_all_balls();
story_versus_spawn_ball_at("obj_ball_player", 380, 350);
story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
story_versus_spawn_ball_at("obj_ball_target", 640, 260);
story_versus_spawn_ball_at("obj_ball_foul", 520, 480);
story_versus_spawn_ball_at("obj_ball_foul", 760, 480);
story_ai_arm_recovery_risk_if_due();
if (!global.story_ai_risk_shot_armed || !global.story_ai_recovery_risk_pending)
    _failures += "recovery-not-armed ";
var _recovery_pick = story_ai_pick_recovery_foul_shot();
if (_recovery_pick == noone) _failures += "recovery-foul-pick-noone ";
else {
    var _recovery_sim = story_ai_simulate_shot(_recovery_pick.direction, _recovery_pick.power);
    if (_recovery_sim == noone || !_recovery_sim.foul) _failures += "recovery-foul-pick-sim ";
}
if (!story_ai_fixture_has_recovery_foul_shot()) _failures += "recovery-foul-fixture ";
var _recovery_ai_base = global.story_ai_score;
global.risk_shot_active = true;
global.story_ai_recovery_risk_pending = true;
global.shot_active = true;
global.shot_scored = true;
global.shot_penalized = false;
global.shot_pending_points = 10000;
story_versus_on_shot_ended();
if (global.story_ai_score != story_score_add(_recovery_ai_base, 10000))
    _failures += "recovery-clean-score ";
if (!global.story_ai_recovery_risk_used || global.story_ai_recovery_risk_pending)
    _failures += "recovery-clean-flags ";
global.story_turn = STORY_TURN_AI;
global.story_ai_score = _recovery_ai_base;
global.story_ai_recovery_risk_used = false;
global.story_ai_recovery_risk_pending = true;
global.risk_shot_active = true;
global.shot_active = true;
global.shot_scored = false;
global.shot_penalized = true;
global.shot_pending_points = 0;
global.story_ai_score = 0;
story_versus_on_shot_ended();
if (global.story_ai_score != 0) _failures += "recovery-foul-score ";
if (!global.story_ai_recovery_risk_used) _failures += "recovery-foul-used ";
global.story_turn = STORY_TURN_AI;
global.story_ai_score = _recovery_ai_base;
global.story_ai_recovery_risk_used = false;
global.story_ai_recovery_risk_pending = true;
global.risk_shot_active = true;
global.shot_active = true;
global.shot_scored = false;
global.shot_penalized = false;
global.shot_pending_points = 0;
story_versus_on_shot_ended();
if (global.story_ai_score != _recovery_ai_base) _failures += "recovery-miss-score ";
if (!global.story_ai_recovery_risk_used) _failures += "recovery-miss-used ";
global.story_turn = STORY_TURN_AI;
global.story_ai_score = 150000;
global.story_ai_risk_shot_armed = false;
global.story_item_used_this_turn = false;
global.story_ai_recovery_due_pair = -1;
global.story_player_score = 0;
story_versus_try_schedule_ai_recovery_risk(40000);
for (var _attempt = 0; _attempt < 100; _attempt++) {
    story_ai_consider_items({ expected_score: 1600, direction: 0 });
}
if (global.story_ai_recovery_due_pair >= 0)
    _failures += "recovery-repeated ";

// Item rules: both sides pay, one purchase per turn, and removal clears every
// foul ball present at purchase time without protecting later balls.
story_versus_init();
global.story_break_pending = false;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_turn = STORY_TURN_AI;
global.story_ai_score = 2000;
with (obj_ball_foul) instance_destroy();
story_versus_spawn_ball_at("obj_ball_foul", 500, 300);
story_versus_spawn_ball_at("obj_ball_foul", 780, 400);
if (!story_versus_purchase_item_for_side(STORY_TURN_AI, 3)
    || global.story_ai_score != 400 || instance_number(obj_ball_foul) != 0)
    _failures += "ai-remove-all ";
if (global.story_ai_item_use_counts[2] != 1 || global.story_foul_removed_total != 2)
    _failures += "item-log ";
if (story_versus_purchase_item_for_side(STORY_TURN_AI, 1)) _failures += "one-item ";
story_versus_spawn_ball_at("obj_ball_foul", 600, 350);
if (instance_number(obj_ball_foul) != 1) _failures += "new-foul ";
if (!story_versus_pass_turn_no_shot("AI ITEM PASS")) _failures += "ai-item-pass ";
if (instance_number(obj_ball_foul) != 3 || !story_test_foul_at(500, 300)
    || !story_test_foul_at(780, 400) || !story_test_foul_at(600, 350))
    _failures += "ai-restore-position ";
with (obj_ball_foul) instance_destroy();
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_player_score = 1000;
story_versus_spawn_ball_at("obj_ball_foul", 500, 300);
story_versus_spawn_ball_at("obj_ball_foul", 780, 400);
if (!story_versus_purchase_item_for_side(STORY_TURN_PLAYER, 3)
    || global.story_player_score != 600 || instance_number(obj_ball_foul) != 0)
    _failures += "player-remove-all ";
global.shot_active = true;
global.shot_scored = false;
global.shot_penalized = false;
global.shot_pending_points = 0;
story_versus_on_shot_ended();
if (instance_number(obj_ball_foul) != 2 || !story_test_foul_at(500, 300)
    || !story_test_foul_at(780, 400)) _failures += "player-restore-position ";
with (obj_ball_foul) instance_destroy();
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_ai_score = 1000;
if (story_versus_purchase_item_for_side(STORY_TURN_AI, 3)
    || global.story_ai_score != 1000) _failures += "remove-zero ";

// Risk can only be purchased at the 100,000-point lead boundary; the
// bartender's purchase must not consume the player's pending risk shot.
global.story_completed_pairs = 15;
global.story_player_score = 103999;
global.story_ai_score = 4000;
global.risk_shot_armed = true;
story_ai_consider_items({ expected_score: 1000 });
if (global.story_ai_risk_shot_armed || global.story_ai_score != 4000)
    _failures += "risk-below ";
if (story_versus_purchase_item_for_side(STORY_TURN_AI, 2)) _failures += "risk-direct-below ";
global.story_player_score = 104000;
story_ai_consider_items({ expected_score: 1000 });
if (!global.story_ai_risk_shot_armed || global.story_ai_score != 800
    || !global.risk_shot_armed || global.story_ai_risk_below_threshold_uses != 0)
    _failures += "risk-boundary ";
story_versus_init();
global.story_break_pending = false;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_turn = STORY_TURN_AI;
global.story_ai_score = 1000;
var _soft_fouls = instance_number(obj_ball_foul);
story_ai_consider_items({ expected_score: 0 });
if (global.story_ai_score != 1000 || instance_number(obj_ball_foul) != _soft_fouls)
    _failures += "soft-no-item ";
global.story_completed_pairs = 15;
with (obj_ball_foul) instance_destroy();
var _ai_place_ball = instance_find(obj_ball_ai, 0);
var _place_bounds = physics_table_bounds();
_ai_place_ball.x = _place_bounds.left + _ai_place_ball.physics_radius + 4;
_ai_place_ball.y = 350;
var _before_ai_x = _ai_place_ball.x;
if (!story_ai_consider_items({ expected_score: 0 })
    || global.story_ai_score != 200 || _ai_place_ball.x == _before_ai_x)
    _failures += "ai-place ";
story_versus_init();
global.story_break_pending = false;
global.story_completed_pairs = 15;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_turn = STORY_TURN_AI;
global.story_ai_score = 1000;
with (obj_ball_foul) instance_destroy();
story_versus_spawn_ball_at("obj_ball_foul", 500, 300);
var _unblocked_fouls = instance_number(obj_ball_foul);
story_ai_consider_items({ expected_score: 1600, direction: 0 });
if (global.story_ai_item_use_counts[2] != 0
    || instance_number(obj_ball_foul) != _unblocked_fouls)
    _failures += "ai-unblocked-no-remove ";
story_versus_init();
global.story_break_pending = false;
global.story_completed_pairs = 15;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_turn = STORY_TURN_AI;
global.story_ai_score = 4000;
global.story_player_score = 104000;
with (obj_ball_foul) instance_destroy();
story_versus_spawn_ball_at("obj_ball_foul", 500, 300);
story_ai_consider_items({ expected_score: 1600, direction: 0 });
if (!global.story_ai_risk_shot_armed || global.story_ai_item_use_counts[1] != 1
    || global.story_ai_item_use_counts[2] != 0) _failures += "ai-risk-before-remove ";
story_versus_init();
global.story_break_pending = false;
global.story_completed_pairs = 15;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
global.story_turn = STORY_TURN_AI;
global.story_ai_score = 2000;
with (obj_ball_foul) instance_destroy();
application_destroy_all_balls();
story_versus_spawn_ball_at("obj_ball_player", 380, 350);
story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
story_versus_spawn_ball_at("obj_ball_target", 640, 260);
story_versus_spawn_ball_at("obj_ball_foul", 760, 350);
story_ai_consider_items({ expected_score: 0, direction: 180 });
if (global.story_ai_item_use_counts[2] != 1 || instance_number(obj_ball_foul) != 0)
    _failures += "ai-blocked-remove ";

// A 5,000-point deficit should allow a real six-cushion comeback path.
var _six_cushion = story_ai_simulate_shot_from_balls(story_ai_fixture_ball_snapshot(), 312, 15);
if (_six_cushion == noone || !_six_cushion.hit_target || _six_cushion.foul
    || _six_cushion.cushions < 6) _failures += "six-cushion-fixture ";
story_versus_init();
global.story_break_pending = false;
global.story_completed_pairs = 15;
global.story_turn = STORY_TURN_AI;
global.story_player_score = 10000;
global.story_ai_score = 5000;
application_destroy_all_balls();
story_versus_spawn_ball_at("obj_ball_player", 380, 350);
story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
story_versus_spawn_ball_at("obj_ball_target", 640, 260);
story_versus_spawn_ball_at("obj_ball_foul", 520, 480);
story_versus_spawn_ball_at("obj_ball_foul", 760, 480);
var _pick_start_us = get_timer();
var _catchup_pick = story_ai_pick_shot();
show_debug_message("AI_CATCHUP_PICK_MS " + string((get_timer() - _pick_start_us) / 1000));
if (_catchup_pick == noone || _catchup_pick.cushions < 6
    || abs(5000 + _catchup_pick.expected_score - 10000) > 2000)
    _failures += "ai-six-cushion-catchup ";
global.story_player_score = 5000;
global.story_ai_score = 10000;
var _ahead_pick = story_ai_pick_shot();
if (_ahead_pick == noone || _ahead_pick.expected_score > 1600)
    _failures += "ai-ahead-holds-back ";
global.story_player_score = 105000;
global.story_ai_score = 5000;
global.story_turn = STORY_TURN_AI;
global.story_item_used_this_turn = false;
global.story_dialogue_timer = 0;
global.story_turn_banner_pending = false;
if (!story_ai_consider_items({ expected_score: 1600, direction: 0 })
    || !global.story_ai_risk_shot_armed) _failures += "ai-risk-repick ";
var _risk_pick = story_ai_pick_shot();
if (_risk_pick == noone || _risk_pick.expected_score
    != story_risk_points_for_cushions(_risk_pick.cushions)
    || _risk_pick.expected_score >= 1000000) _failures += "ai-risk-score-aware ";

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
