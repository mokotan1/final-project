rules_init(true);
application_spawn_initial_balls();
result_overlay_opened = false;
// A newly created game room always starts unpaused, including after returning
// from the main menu during an earlier paused run.
global.game_settings_open = false;
