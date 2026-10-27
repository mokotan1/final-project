result_score = variable_global_exists("score") ? global.score : 0;
lang_init(); lang_font_init();
result_best = variable_global_exists("best_score") ? global.best_score : result_score;
button_hover = false;
menu_hover = false;
ui_press_frames = 0;
ui_press_action = "";
depth = -10000;
