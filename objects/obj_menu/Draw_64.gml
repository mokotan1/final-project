var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _cx = _w * 0.5;
var _cy = _h * 0.5;
var _charcoal = make_color_rgb(39, 47, 43);
var _brass = make_color_rgb(211, 169, 78);
var _cream = make_color_rgb(236, 231, 204);
var _muted = make_color_rgb(164, 188, 173);
var _panel = make_color_rgb(16, 79, 58);
lang_font_init(); draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_alpha(1);
if (menu_story_opening) {
    draw_set_color(c_white);
    draw_sprite(spr_story_opening, 0, 0, 0);
    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(18, 660, 410, 708, false);
    draw_set_alpha(1);
    draw_set_color(_cream);
    pixel_draw_text_transformed(32, 676,
        tr("ENTER / CLICK: START   ESC: BACK", "클릭 / ENTER: 시작   ESC: 뒤로"), 1, 1, 0, false);
    var _prompt_alpha = 0.15 + 0.85 * (0.5 + 0.5 * sin(get_timer() * 0.000006));
    draw_set_alpha(_prompt_alpha);
    draw_set_color(c_black);
    pixel_draw_text_transformed(_cx + 2, 674, tr("PRESS ENTER TO START", "시작하려면 클릭하세요"), 2, 2, 0, true);
    draw_set_color(_cream);
    pixel_draw_text_transformed(_cx, 672, tr("PRESS ENTER TO START", "시작하려면 클릭하세요"), 2, 2, 0, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}
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
    draw_sprite(spr_mode_select_bg, 0, 0, 0);
    var _idle_frame = 0;
    if (menu_idle_tick >= 60) _idle_frame = 1;
    if (menu_idle_tick >= 65) _idle_frame = 2;
    draw_sprite_ext(spr_assistant_bar_idle, _idle_frame, 300, 500, 0.8, 0.8, 0, c_white, 1);
    if (menu_talk_tick >= 0) {
        var _talk_pose = [2, 3, 2, 4, 2, 5];
        var _talk_frame = _talk_pose[min(5, floor(menu_talk_tick / 12))];
        draw_sprite_part_ext(spr_assistant_desk_talk, _talk_frame,
            238, 208, 32, 27, 300 + (238 - 256) * 0.8 + 2,
            500 + (208 - 512) * 0.8 + 4, 0.8, 0.8, c_white, 1);
    }
    draw_sprite_part(spr_mode_select_bg, 0, 0, 500, 700, 220, 0, 500);
    var _endless_selected = (menu_selected_mode == GAME_MODE_ENDLESS);
    var _story_selected = menu_selected_story;
    ui_button_draw("STORY", 695, 90, UI_BUTTON_L_W, UI_BUTTON_L_H, true,
        ui_button_is_pressed(id, "story") ? UI_BUTTON_PRESSED : (_story_selected ? UI_BUTTON_SELECTED : ui_button_state(menu_hover_story)));
    ui_button_draw("ENDLESS", 695, 197, UI_BUTTON_L_W, UI_BUTTON_L_H, true,
        ui_button_is_pressed(id, "endless") ? UI_BUTTON_PRESSED : ((!_story_selected && _endless_selected) ? UI_BUTTON_SELECTED : ui_button_state(menu_hover_endless)));
    ui_button_draw("CLASSIC", 695, 304, UI_BUTTON_L_W, UI_BUTTON_L_H, true,
        ui_button_is_pressed(id, "classic") ? UI_BUTTON_PRESSED : ((!_story_selected && !_endless_selected) ? UI_BUTTON_SELECTED : ui_button_state(menu_hover_classic)));
    draw_set_color(c_black);
    draw_triangle(600, 551, 647, 514, 647, 560, false);
    draw_rectangle(632, 411, 1242, 563, false);
    draw_set_color(_brass);
    draw_triangle(607, 548, 643, 521, 643, 554, false);
    draw_rectangle(636, 407, 1236, 557, false);
    draw_set_color(make_color_rgb(5, 48, 45));
    draw_triangle(620, 544, 651, 528, 651, 548, false);
    draw_rectangle(643, 414, 1229, 550, false);
    draw_set_color(make_color_rgb(25, 113, 93));
    draw_rectangle(654, 424, 1218, 428, false);
    draw_set_color(_brass);
    pixel_draw_text_transformed(940, 454,
        _story_selected ? tr("STORY", "스토리") : (_endless_selected ? tr("ENDLESS", "무한") : tr("CLASSIC", "클래식")),
        2, 2, 0, true);
    draw_set_color(_cream);
    pixel_draw_text_transformed(940, 495,
        _story_selected ? tr("A bar bet starts the story.", "술값 내기로 이야기를 시작해요.")
        : (_endless_selected ? tr("Collect items. Chase your best.", "아이템을 모아 최고 기록에 도전해요.")
        : tr("Four fouls. Every shot counts.", "순수한 샷. 파울 한도 4.")),
        2, 2, 0, false);
    draw_set_color(_muted);
    pixel_draw_text_transformed(1090, 540, tr("ESC: MENU", "ESC: 메뉴"), 1, 1, 0, false);
    ui_button_draw("BACK", 20, 590, UI_BUTTON_M_W, UI_BUTTON_M_H, true,
        ui_button_state(menu_hover_back, ui_button_is_pressed(id, "back")));
    ui_button_draw("START", 780, 590, UI_BUTTON_M_W, UI_BUTTON_M_H, true,
        ui_button_state(menu_hover_start, ui_button_is_pressed(id, "start")));
}

if (menu_settings_open) {
    if (global.audio_enabled) draw_sprite(spr_menu_settings_on, 0, 0, 0); else draw_sprite(spr_menu_settings_off, 0, 0, 0);
    ui_settings_panel_draw(_cx, "DONE", ui_button_state(menu_hover_settings_done, ui_button_is_pressed(id, "done")));
}
draw_set_alpha(1); draw_set_color(c_white);
