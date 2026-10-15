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

// Independent light layers keep the skyline calm while the bar sign sputters.
var _night_t = get_timer() * 0.000001;
var _star_a = 0.35 + 0.40 * (0.5 + 0.5 * sin(_night_t * 2.1));
draw_sprite_part_ext(spr_menu_stars_glow, 0, 0, 0, 640, 720, 0, 0, 1, 1, c_white, _star_a);
draw_sprite_part_ext(spr_menu_stars_glow, 0, 640, 0, 640, 720, 640, 0, 1, 1, c_white,
    0.35 + 0.40 * (0.5 + 0.5 * sin(_night_t * 1.6 + 1.9)));
draw_sprite_part_ext(spr_menu_windows_glow, 0, 0, 0, 640, 720, 0, 0, 1, 1, c_white,
    0.35 + 0.50 * (0.5 + 0.5 * sin(_night_t * 0.9 + 0.7)));
draw_sprite_part_ext(spr_menu_windows_glow, 0, 640, 0, 640, 720, 640, 0, 1, 1, c_white,
    0.35 + 0.50 * (0.5 + 0.5 * sin(_night_t * 1.2 + 2.4)));
var _neon_tick = floor(_night_t * 14) mod 71;
var _neon_a = 0.95;
if (_neon_tick == 11 || _neon_tick == 13 || _neon_tick == 14) _neon_a = 0.08;
else if (_neon_tick == 12 || _neon_tick == 15) _neon_a = 0.48;
draw_sprite_ext(spr_menu_neon_glow, 0, 0, 0, 1, 1, 0, c_white, _neon_a);

if (menu_view == 0) {
    var _menu_x = 500;
    draw_set_font(lang_font());
    draw_set_color(c_black);
    pixel_draw_menu_text(_menu_x + 3, 118, "CUSHION", 5, true);
    draw_set_color(_cream);
    pixel_draw_menu_text(_menu_x, 115, "CUSHION", 5, true);
    draw_set_color(c_black);
    pixel_draw_menu_text(_menu_x + 2, 172, "CHALLENGE", 3);
    draw_set_color(_brass);
    pixel_draw_menu_text(_menu_x, 170, "CHALLENGE", 3);
    draw_set_color(c_black);
    pixel_draw_menu_text(_menu_x + 1, 210, tr("RISK. REWARD. ANGLES.", "각도의 승부"), 2);
    draw_set_color(make_color_rgb(205, 207, 187));
    pixel_draw_menu_text(_menu_x, 209, tr("RISK. REWARD. ANGLES.", "각도의 승부"), 2);

    draw_set_color(c_black);
    pixel_draw_menu_text(_menu_x + 2, 492, tr("PLAY", "시작"), 3, menu_hover_play);
    draw_set_color(menu_hover_play ? _brass : _cream);
    pixel_draw_menu_text(_menu_x, 490, tr("PLAY", "시작"), 3, menu_hover_play);
    draw_set_color(c_black);
    pixel_draw_menu_text(_menu_x + 2, 562, tr("SETTINGS", "설정"), 3, menu_hover_settings);
    draw_set_color(menu_hover_settings ? _brass : _cream);
    pixel_draw_menu_text(_menu_x, 560, tr("SETTINGS", "설정"), 3, menu_hover_settings);
    draw_set_color(c_black);
    pixel_draw_menu_text(_menu_x + 2, 632, tr("EXIT", "종료"), 3, menu_hover_quit);
    draw_set_color(menu_hover_quit ? _brass : _cream);
    pixel_draw_menu_text(_menu_x, 630, tr("EXIT", "종료"), 3, menu_hover_quit);
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
