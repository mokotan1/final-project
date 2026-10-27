#macro UI_BUTTON_IDLE 0
#macro UI_BUTTON_HOVER 1
#macro UI_BUTTON_PRESSED 2
#macro UI_BUTTON_SELECTED 3
#macro UI_BUTTON_DISABLED 4
#macro UI_BUTTON_L_W 381
#macro UI_BUTTON_L_H 100
#macro UI_BUTTON_M_W 286
#macro UI_BUTTON_M_H 85
#macro UI_BUTTON_S_W 240
#macro UI_BUTTON_S_H 60

function ui_button_hit(_mx, _my, _x, _y, _w, _h) {
    return point_in_rectangle(_mx, _my, _x, _y, _x + _w, _y + _h);
}

function ui_button_state(_hover, _pressed = false) {
    if (_pressed) return UI_BUTTON_PRESSED;
    if (_hover) return UI_BUTTON_HOVER;
    return UI_BUTTON_IDLE;
}

function ui_button_press_start(_owner, _action) {
    if (_owner.ui_press_frames > 0) return false;
    _owner.ui_press_action = _action;
    _owner.ui_press_frames = 6;
    audio_sfx("snd_ui_click", 0.7);
    return true;
}

function ui_button_press_tick(_owner) {
    if (_owner.ui_press_frames <= 0) return "";
    _owner.ui_press_frames -= 1;
    if (_owner.ui_press_frames > 0) return "";
    var _action = _owner.ui_press_action;
    _owner.ui_press_action = "";
    return _action;
}

function ui_button_is_pressed(_owner, _action) {
    return _owner.ui_press_frames > 0 && _owner.ui_press_action == _action;
}

/// Pixel-art menu button (START / mode select style).
function ui_button_draw(_label, _x, _y, _bw, _bh, _dark, _state) {
    var _disabled = (_state == UI_BUTTON_DISABLED);
    var _pressed = (_state == UI_BUTTON_PRESSED);
    var _shift = _pressed ? 3 : 0;
    var _bx = _x + _shift;
    var _by = _y + _shift;
    var _fill = _dark ? make_color_rgb(5, 62, 52) : make_color_rgb(216, 158, 65);
    if (_state == UI_BUTTON_HOVER || _state == UI_BUTTON_SELECTED) _fill = _dark ? make_color_rgb(18, 102, 82) : make_color_rgb(255, 190, 82);
    if (_pressed) _fill = _dark ? make_color_rgb(8, 86, 68) : make_color_rgb(151, 100, 39);
    var _old_alpha = draw_get_alpha();
    if (_disabled) draw_set_alpha(_old_alpha * 0.45);
    draw_set_color(c_black);
    draw_rectangle(_x + 5, _y + 7, _x + _bw + 5, _y + _bh + 7, false);
    draw_set_color((_state == UI_BUTTON_HOVER || _state == UI_BUTTON_SELECTED) ? make_color_rgb(255, 222, 117) : make_color_rgb(211, 169, 78));
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
    draw_set_color(make_color_rgb(38, 27, 17));
    draw_rectangle(_bx + 5, _by + 5, _bx + _bw - 5, _by + _bh - 5, false);
    draw_set_color(_fill);
    draw_rectangle(_bx + 9, _by + 9, _bx + _bw - 9, _by + _bh - 9, false);
    draw_set_color((_state == UI_BUTTON_HOVER || _state == UI_BUTTON_SELECTED) ? c_white : make_color_rgb(211, 169, 78));
    draw_rectangle(_bx + 13, _by + 13, _bx + _bw - 13, _by + _bh - 13, true);
    draw_set_color(_dark ? make_color_rgb(236, 231, 204) : make_color_rgb(43, 27, 15));
    var _label_scale = (_bh <= UI_BUTTON_S_H) ? 2 : 3;
    if (_bw <= 80) _label_scale = 1;
    if (_label != "") {
        if (_bh <= UI_BUTTON_S_H) pixel_draw_menu_text(_bx + _bw * 0.5, _by + _bh * 0.5,
            _label, _label_scale, true, 8, 8);
        else pixel_draw_menu_text(_bx + _bw * 0.5, _by + _bh * 0.5, _label, _label_scale, true, 6, 8);
    }
    draw_set_alpha(_old_alpha);
}

function ui_menu_title_button_rect(_menu_x, _row) {
    var _w = UI_BUTTON_M_W;
    var _h = UI_BUTTON_M_H;
    var _y = 430 + _row * 95;
    return { x: _menu_x - _w * 0.5, y: _y, w: _w, h: _h };
}

function ui_result_play_rect(_cx, _cy) {
    return { x: _cx - UI_BUTTON_S_W * 0.5, y: _cy + 100, w: UI_BUTTON_S_W, h: UI_BUTTON_S_H };
}

function ui_result_menu_rect(_cx, _cy) {
    return { x: _cx - UI_BUTTON_S_W * 0.5, y: _cy + 168, w: UI_BUTTON_S_W, h: UI_BUTTON_S_H };
}

function ui_settings_primary_rect(_cx) {
    return { x: _cx - UI_BUTTON_S_W * 0.5, y: 478, w: UI_BUTTON_S_W, h: UI_BUTTON_S_H };
}

function ui_settings_secondary_rect(_cx) {
    return { x: _cx - UI_BUTTON_S_W * 0.5, y: 540, w: UI_BUTTON_S_W, h: UI_BUTTON_S_H };
}

/// Settings panel body shared by menu and in-game pause overlay.
function ui_settings_panel_draw(_cx, _primary_label, _primary_state, _secondary_label = "", _secondary_state = -1) {
    var _panel = make_color_rgb(16, 79, 58);
    var _brass = make_color_rgb(211, 169, 78);
    var _cream = make_color_rgb(236, 231, 204);
    var _muted = make_color_rgb(164, 188, 173);
    var _charcoal = make_color_rgb(39, 47, 43);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_panel);
    draw_rectangle(_cx - 290, 145, _cx + 290, 605, false);
    draw_set_color(_brass);
    draw_rectangle(_cx - 278, 157, _cx + 278, 593, true);
    draw_set_color(_brass);
    pixel_draw_text_transformed(_cx, 218, tr("SETTINGS", "설정"), 2, 2, 0, true);
    draw_set_color(_muted);
    pixel_draw_text_transformed(_cx, 274, tr("SOUND", "음량"), 2, 2, 0, true);
    var _volume = audio_volume_get();
    var _bar_l = _cx - 240;
    var _bar_r = _cx + 240;
    draw_set_color(_charcoal);
    draw_rectangle(_bar_l, 320, _bar_r, 344, false);
    draw_set_color(_brass);
    draw_rectangle(_bar_l, 320, _bar_l + (_bar_r - _bar_l) * _volume, 344, false);
    draw_set_color(_cream);
    draw_rectangle(_bar_l + (_bar_r - _bar_l) * _volume - 8, 312, _bar_l + (_bar_r - _bar_l) * _volume + 8, 352, false);
    draw_set_color(_brass);
    pixel_draw_text_transformed(_cx, 378, string(round(_volume * 100)) + "%", 2, 2, 0, true);
    draw_set_color(_muted);
    pixel_draw_text_transformed(_cx, 410, tr("LANGUAGE", "언어"), 2, 2, 0, true);
    draw_set_color(_brass);
    pixel_draw_text_transformed(_cx, 452, lang_is_korean() ? "한국어" : "ENGLISH", 3, 3, 0, true);
    var _primary = ui_settings_primary_rect(_cx);
    ui_button_draw(_primary_label, _primary.x, _primary.y, _primary.w, _primary.h, true, _primary_state);
    if (_secondary_label != "") {
        var _secondary = ui_settings_secondary_rect(_cx);
        ui_button_draw(_secondary_label, _secondary.x, _secondary.y, _secondary.w, _secondary.h, true, _secondary_state);
    }
}
