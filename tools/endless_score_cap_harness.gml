// Test-only Runner fixture. The actual rules functions calculate each payout.
// The two shots are deterministic injected states, not manual billiards play.
risk_cap_fixture_frame += 1;
if (risk_cap_fixture_frame < 140) {
    global.game_over = false;
    global.chances = 3;
}
if (risk_cap_fixture_frame == 10 || risk_cap_fixture_frame == 70) {
    global.score = 999999000;
    global.best_score = 999999000;
    global.place_mode = false;
    global.risk_shot_armed = true;
    var _cue_ball = { x: 500, y: 350 };
    var _target_ball = { x: 650, y: 350 };
    var _cushions = (risk_cap_fixture_frame == 10) ? 2 : 3;
    var _started = rules_on_shot_started(_cue_ball);
    rules_on_cushion_hit(_cue_ball, _cushions);
    rules_on_target_hit(_cue_ball, _target_ball, _cushions);
    var _pending = global.shot_pending_points;
    rules_on_shot_ended();
    show_debug_message("RISK_CAP_FIXTURE cushion=" + string(_cushions)
        + " started=" + string(_started)
        + " pending=" + string(_pending)
        + " score=" + string(global.score)
        + " best=" + string(global.best_score));
}
if (risk_cap_fixture_frame == 140) {
    global.chances = 0;
    rules_finish_game();
    show_debug_message("RISK_CAP_FIXTURE result score=" + string(global.score)
        + " best=" + string(global.best_score)
        + " saved=" + string(game_mode_read_saved_best_score()));
}
