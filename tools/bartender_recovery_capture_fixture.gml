// Temporary visual fixture for bartender recovery risk capture; not a registered resource.
if (!variable_global_exists("recovery_capture_phase")) global.recovery_capture_phase = 0;
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
global.story_ai_recovery_risk_used = false;
global.story_ai_recovery_risk_pending = false;
global.story_ai_risk_shot_armed = false;
global.story_item_used_this_turn = false;
application_destroy_all_balls();
story_versus_spawn_ball_at("obj_ball_player", 380, 350);
story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
story_versus_spawn_ball_at("obj_ball_target", 640, 260);
story_versus_spawn_ball_at("obj_ball_foul", 520, 480);
story_versus_spawn_ball_at("obj_ball_foul", 760, 480);
if (global.recovery_capture_phase == 0) {
    // Stable lead without a player score loss on this hand.
    global.story_player_score = 120000;
    global.story_ai_score = 230000;
    story_ai_consider_items({ expected_score: 1600, direction: 0 });
    show_debug_message("RECOVERY_CAPTURE phase=0 due=" + string(global.story_ai_recovery_due_pair)
        + " ai=" + string(global.story_ai_score) + " player=" + string(global.story_player_score));
} else if (global.recovery_capture_phase == 1) {
    global.story_player_score = 45000;
    global.story_ai_score = 160000;
    var _before = global.story_player_score;
    global.story_player_score = 0;
    story_versus_try_schedule_ai_recovery_risk(_before);
    show_debug_message("RECOVERY_CAPTURE phase=1 due=" + string(global.story_ai_recovery_due_pair)
        + " ai=" + string(global.story_ai_score) + " player=" + string(global.story_player_score));
} else {
    global.story_player_score = 0;
    global.story_ai_score = 180000;
    global.story_ai_recovery_due_pair = 16;
    global.story_completed_pairs = 15;
    story_ai_arm_recovery_risk_if_due();
    var _pick = story_ai_pick_recovery_foul_shot();
    var _sim_foul = (_pick != noone)
        ? story_ai_simulate_shot(_pick.direction, _pick.power).foul : false;
    show_debug_message("RECOVERY_CAPTURE phase=2 pending=" + string(global.story_ai_recovery_risk_pending)
        + " risk_armed=" + string(global.story_ai_risk_shot_armed)
        + " foul_pick=" + string(_pick != noone)
        + " sim_foul=" + string(_sim_foul)
        + " dir=" + string(_pick != noone ? _pick.direction : -1)
        + " power=" + string(_pick != noone ? _pick.power : -1));
}
