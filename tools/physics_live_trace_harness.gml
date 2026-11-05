// Build-time harness for GM Runner live obj_ball trace (312°/15 fixture).
// Wired by tools/build_physics_live_trace.ps1 — not a registered GameMaker resource.

function physics_live_trace_role_name(_object) {
    if (_object == obj_ball_player) return "Player";
    if (_object == obj_ball_ai) return "AiStriker";
    if (_object == obj_ball_target) return "Target";
    if (_object == obj_ball_foul) return "Foul";
    return "Unknown";
}

function physics_live_trace_push_ball(_balls, _inst) {
    array_push(_balls, {
        role: physics_live_trace_role_name(_inst.object_index),
        x: _inst.x,
        y: _inst.y,
        vx: _inst.hspeed,
        vy: _inst.vspeed,
        lock: _inst.physics_cushion_lock
    });
}

function physics_live_trace_collect_balls() {
    var _balls = [];
    var _player = instance_find(obj_ball_player, 0);
    if (_player != noone) physics_live_trace_push_ball(_balls, _player);
    var _ai = instance_find(obj_ball_ai, 0);
    if (_ai != noone) physics_live_trace_push_ball(_balls, _ai);
    var _target = instance_find(obj_ball_target, 0);
    if (_target != noone) physics_live_trace_push_ball(_balls, _target);
    var _foul_ids = [];
    with (obj_ball_foul) array_push(_foul_ids, id);
    array_sort(_foul_ids, true);
    for (var _f = 0; _f < min(2, array_length(_foul_ids)); _f++)
        physics_live_trace_push_ball(_balls, _foul_ids[_f]);
    return _balls;
}

function physics_live_trace_num(_value) {
    return string_format(_value, 0, 6);
}

function physics_live_trace_balls_json(_balls) {
    var _s = "[";
    for (var _i = 0; _i < array_length(_balls); _i++) {
        if (_i > 0) _s += ",";
        var _b = _balls[_i];
        _s += "{\"role\":\"" + _b.role + "\"";
        _s += ",\"x\":" + physics_live_trace_num(_b.x);
        _s += ",\"y\":" + physics_live_trace_num(_b.y);
        _s += ",\"vx\":" + physics_live_trace_num(_b.vx);
        _s += ",\"vy\":" + physics_live_trace_num(_b.vy);
        _s += ",\"lock\":" + string(_b.lock) + "}";
    }
    _s += "]";
    return _s;
}

function physics_live_trace_frame_json(_step, _events) {
    var _s = "{\"step\":" + string(_step) + ",\"events\":[";
    for (var _e = 0; _e < array_length(_events); _e++) {
        if (_e > 0) _s += ",";
        _s += "\"" + _events[_e] + "\"";
    }
    _s += "],\"balls\":" + physics_live_trace_balls_json(physics_live_trace_collect_balls()) + "}";
    return _s;
}

function physics_live_trace_outcome_json() {
    var _cushions = variable_global_exists("shot_cushion_count") ? global.shot_cushion_count : 0;
    var _hit = variable_global_exists("shot_scored") && global.shot_scored;
    var _foul = variable_global_exists("shot_penalized") && global.shot_penalized;
    var _score = 0;
    if (_hit && !_foul && variable_global_exists("shot_pending_points"))
        _score = global.shot_pending_points;
    var _s = "{\"cushions\":" + string(_cushions);
    _s += ",\"hit_target\":" + (_hit ? "true" : "false");
    _s += ",\"foul\":" + (_foul ? "true" : "false");
    _s += ",\"score\":" + string(_score) + "}";
    return _s;
}

function physics_live_trace_finish(_reason) {
    global.physics_live_trace_active = false;
    show_debug_message("PHYSICS_LIVE_TRACE_OUTCOME " + physics_live_trace_outcome_json());
    show_debug_message("PHYSICS_LIVE_TRACE_DONE reason=" + _reason + " frames=" + string(global.physics_live_trace_step));
    game_end();
}

function physics_live_trace_setup_and_shoot() {
    global.physics_live_trace_active = true;
    global.physics_live_trace_step = 0;
    global.physics_live_trace_max = 720;
    global.physics_live_trace_events = [];
    global.story_break_pending = false;
    global.story_shot_is_break = false;
    global.story_dialogue_timer = 0;
    global.story_reaction_timer = 0;
    global.story_rule_dialogue_index = 2;
    global.story_turn_banner_pending = false;
    global.story_turn_banner_timer = 0;
    global.story_turn = STORY_TURN_AI;
    global.story_completed_pairs = 15;
    global.story_ai_recovery_due_pair = -1;
    application_destroy_all_balls();
    story_versus_spawn_ball_at("obj_ball_player", 380, 350);
    story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
    story_versus_spawn_ball_at("obj_ball_target", 640, 260);
    story_versus_spawn_ball_at("obj_ball_foul", 520, 480);
    story_versus_spawn_ball_at("obj_ball_foul", 760, 480);
    ai_turn_delay = 999999;
    var _striker = instance_find(obj_ball_ai, 0);
    if (!physics_shoot(_striker, 312, 15)) {
        show_debug_message("PHYSICS_LIVE_TRACE_FAIL shoot");
        game_end();
    }
}

global.physics_live_trace_banner = "PHYSICS_LIVE_TRACE_HARNESS_V2";
