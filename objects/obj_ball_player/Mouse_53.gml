if (variable_global_exists("place_mode") && global.place_mode) {
    if (application_place_player_ball(id, mouse_x, mouse_y)) {
        with (obj_cue) {
            dragging = false;
            shot_input_lock = 2;
        }
    }
}
