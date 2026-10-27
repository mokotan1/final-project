// Temporary full-physics playthrough driver, prepended to the story controller Step.
global.story_dialogue_timer = 0;
global.story_reaction_timer = 0;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
if (global.story_turn == STORY_TURN_AI) ai_turn_delay = 1;
if (!variable_global_exists("story_autoplay_last_reported")) global.story_autoplay_last_reported = -1;
if (global.story_completed_pairs != global.story_autoplay_last_reported) {
    global.story_autoplay_last_reported = global.story_completed_pairs;
    var _progress_file = file_text_open_write("story50_autoplay_progress_final.txt");
    file_text_write_string(_progress_file, "pairs=" + string(global.story_completed_pairs)
        + " player=" + string(global.story_player_score)
        + " ai=" + string(global.story_ai_score));
    file_text_close(_progress_file);
}
if (global.story_match_over) {
    var _done_file = file_text_open_write("story50_autoplay_result_final.txt");
    file_text_write_string(_done_file, "pairs=" + string(global.story_completed_pairs)
        + " player=" + string(global.story_player_score)
        + " ai=" + string(global.story_ai_score)
        + " winner=" + string(global.story_winner));
    file_text_close(_done_file);
    game_end();
    exit;
}
if (story_versus_is_human_turn()) {
    var _player_ball = instance_find(obj_ball_player, 0);
    var _target_ball = instance_find(obj_ball_target, 0);
    if (!instance_exists(_player_ball) || !instance_exists(_target_ball)) {
        var _error_file = file_text_open_write("story50_autoplay_result_final.txt");
        file_text_write_string(_error_file, "FAIL missing player or target at pair "
            + string(global.story_completed_pairs));
        file_text_close(_error_file);
        game_end();
        exit;
    }
    physics_shoot(_player_ball,
        point_direction(_player_ball.x, _player_ball.y, _target_ball.x, _target_ball.y), 12);
}
