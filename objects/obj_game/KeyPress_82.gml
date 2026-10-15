if (variable_global_exists("game_settings_open") && global.game_settings_open) exit;
if (variable_global_exists("game_over") && global.game_over && instance_exists(obj_result)) exit;
application_restart_game();
