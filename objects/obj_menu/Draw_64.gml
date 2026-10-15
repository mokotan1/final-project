var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _cx = _w * 0.5;
var _cy = _h * 0.5;
var _charcoal = make_color_rgb(39, 47, 43);
var _brass = make_color_rgb(211, 169, 78);
var _cream = make_color_rgb(236, 231, 204);
var _muted = make_color_rgb(164, 188, 173);
var _panel = make_color_rgb(16, 79, 58);
draw_set_font(-1); draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_alpha(1);
draw_sprite(spr_menu_background, 0, 0, 0);

if (menu_view == 0) {
    draw_sprite(spr_menu_static, 0, _cx - 300, 102);
    if (menu_hover_play) { draw_set_color(_brass); draw_rectangle(_cx - 150, 330, _cx + 150, 390, true); }
    if (menu_hover_settings) { draw_set_color(_brass); draw_rectangle(_cx - 150, 412, _cx + 150, 472, true); }
    if (menu_hover_quit) { draw_set_color(_brass); draw_rectangle(_cx - 150, 494, _cx + 150, 554, true); }
    if (lang_is_korean()) {
        // The title sprite already contains a smaller CHALLENGE and an English
        // tagline. Replace that strip with one larger title in Korean mode.
        draw_set_color(_panel); draw_rectangle(_cx - 220, 232, _cx + 220, 318, false);
        draw_set_color(make_color_rgb(240, 211, 138));
        pixel_draw_text_transformed(_cx, 285, "CHALLENGE", 3, 3, 0);
    }
}

if (menu_view == 1) {
    if (menu_selected_mode == GAME_MODE_ENDLESS) draw_sprite(spr_mode_endless, 0, 0, 0); else draw_sprite(spr_mode_classic, 0, 0, 0);
    if (menu_hover_endless) { draw_set_color(_brass); draw_rectangle(750, 165, 1145, 265, true); }
    if (menu_hover_classic) { draw_set_color(_brass); draw_rectangle(750, 345, 1145, 445, true); }
    if (menu_hover_start) { draw_set_color(_brass); draw_rectangle(195, 578, 445, 632, true); }
    // The sprite contains English copy in the info area. Redraw that area in
    // either language so headings and score share one font and baseline grid.
    draw_set_font(lang_font());
    var _endless_selected = (menu_selected_mode == GAME_MODE_ENDLESS);
    draw_set_color(make_color_rgb(68, 40, 27));
    draw_rectangle(108, 374, 558, 568, false);
    draw_set_color(make_color_rgb(210, 214, 194));
    draw_rectangle(112, 378, 554, 564, false);
    draw_set_color(_charcoal);
    pixel_draw_text_transformed(332, 397, tr("SELECTED MODE", "선택한 모드"), 2, 2, 0, true);
    draw_set_color(make_color_rgb(68, 40, 27));
    pixel_draw_text_transformed(332, 438, tr_mode(menu_selected_mode), 3, 3, 0, true);
    draw_set_color(_charcoal);
    pixel_draw_text_transformed(332, 477, _endless_selected ? tr("ITEMS / MILESTONES", "아이템과 보상") : tr("PURE SHOT / FOUL CAP 4", "순수 샷 / 파울 한도 4"), 2, 2, 0);
    pixel_draw_text_transformed(332, 509, tr("BEST SCORE", "최고 기록"), 2, 2, 0, true);
    draw_set_color(make_color_rgb(68, 40, 27));
    pixel_draw_text_transformed(332, 546, pixel_score_text(_endless_selected ? menu_best_endless : menu_best_classic), 2, 2, 0, true);
}

if (menu_settings_open) {
    if (global.audio_enabled) draw_sprite(spr_menu_settings_on, 0, 0, 0); else draw_sprite(spr_menu_settings_off, 0, 0, 0);
    draw_set_font(lang_font()); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    // Shared, high contrast settings controls. Coordinates mirror obj_ui so
    // opening settings from either context feels identical.
    draw_set_color(_panel); draw_rectangle(_cx - 290, 145, _cx + 290, 605, false);
    draw_set_color(_brass); draw_rectangle(_cx - 278, 157, _cx + 278, 593, true);
    draw_set_color(_brass); pixel_draw_text_transformed(_cx, 218, tr("SETTINGS", "설정"), 2, 2, 0, true);
    draw_set_color(_muted); pixel_draw_text_transformed(_cx, 274, tr("SOUND", "음량"), 2, 2, 0, true);
    var _volume = audio_volume_get();
    var _bar_l = _cx - 240; var _bar_r = _cx + 240;
    draw_set_color(make_color_rgb(39, 47, 43)); draw_rectangle(_bar_l, 320, _bar_r, 344, false);
    draw_set_color(_brass); draw_rectangle(_bar_l, 320, _bar_l + (_bar_r - _bar_l) * _volume, 344, false);
    draw_set_color(_cream); draw_rectangle(_bar_l + (_bar_r - _bar_l) * _volume - 8, 312, _bar_l + (_bar_r - _bar_l) * _volume + 8, 352, false);
    draw_set_color(_brass); pixel_draw_text_transformed(_cx, 378, string(round(_volume * 100)) + "%", 2, 2, 0, true);
    draw_set_color(_muted); pixel_draw_text_transformed(_cx, 410, tr("LANGUAGE", "언어"), 2, 2, 0, true);
    draw_set_color(_brass); pixel_draw_text_transformed(_cx, 452, lang_is_korean() ? "한국어" : "ENGLISH", 3, 3, 0, true);
    draw_set_color(make_color_rgb(68, 40, 27)); draw_rectangle(_cx - 120, 478, _cx + 120, 532, false);
    draw_set_color(_cream); pixel_draw_text_transformed(_cx, 505, "DONE", 2, 2, 0, true);
}
draw_set_alpha(1); draw_set_color(c_white);
