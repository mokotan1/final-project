var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _cx = _gui_w * 0.5;
var _cy = _gui_h * 0.5;
var _cream = make_color_rgb(236, 231, 204);
var _gold = make_color_rgb(240, 211, 138);
var _green = make_color_rgb(16, 79, 58);

lang_font_init();
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
// Keep the final table visible behind the result, while preventing the HUD
// and balls from competing with its text.
draw_set_alpha(0.78);
draw_set_color(make_color_rgb(3, 17, 15));
draw_rectangle(0, 0, _gui_w, _gui_h, false);
draw_set_alpha(1);
draw_set_color(_green);
draw_rectangle(_cx - 350, _cy - 250, _cx + 350, _cy + 260, false);
draw_set_color(_gold);
draw_rectangle(_cx - 338, _cy - 238, _cx + 338, _cy + 248, true);

draw_set_color(_gold);
pixel_draw_text_transformed(_cx, _cy - 205, tr("GAME OVER", "게임 오버"), 3, 3, 0, true, 8);
draw_set_color(make_color_rgb(180, 210, 200));
pixel_draw_text_transformed(_cx, _cy - 160, tr_mode() + tr(" MODE", " 모드"), 2, 2, 0, false, 8);

draw_set_color(_cream);
pixel_draw_text_transformed(_cx, _cy - 113, tr("FINAL SCORE", "최종 점수"), 2, 2, 0, true, 8);
pixel_draw_text_transformed(_cx, _cy - 73, pixel_score_text(result_score), 3, 3, 0, true, 8);
draw_set_color(_gold);
pixel_draw_text_transformed(_cx, _cy - 13, tr("BEST SCORE", "최고 점수"), 2, 2, 0, true, 8);
pixel_draw_text_transformed(_cx, _cy + 27, pixel_score_text(result_best), 3, 3, 0, true, 8);

var _status = "";
var _status_color = _cream;
if (variable_global_exists("best_save_failed") && global.best_save_failed) {
    _status = tr("BEST SCORE SAVE FAILED", "최고 기록 저장 실패");
    _status_color = make_color_rgb(255, 150, 120);
} else if (result_score > result_best || (variable_global_exists("new_best_shown") && global.new_best_shown)) {
    _status = tr("NEW BEST", "새 기록");
    _status_color = make_color_rgb(255, 235, 120);
} else if (result_best > result_score) {
    _status = tr("TO BEST ", "최고까지 ") + pixel_score_text(result_best - result_score);
}
if (_status != "") {
    draw_set_color(_status_color);
    pixel_draw_text_transformed(_cx, _cy + 70, _status, 2, 2, 0, false, 8);
}

var _play_btn = ui_result_play_rect(_cx, _cy);
ui_button_draw("PLAY AGAIN", _play_btn.x, _play_btn.y, _play_btn.w, _play_btn.h, true,
    ui_button_state(button_hover, ui_button_is_pressed(id, "again")));
var _menu_btn = ui_result_menu_rect(_cx, _cy);
ui_button_draw("MAIN MENU", _menu_btn.x, _menu_btn.y, _menu_btn.w, _menu_btn.h, false,
    ui_button_state(menu_hover, ui_button_is_pressed(id, "menu")));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
