/// Galmuri11 is rasterized at the requested draw size, avoiding scaled 12x14 sprite crops.
function ui_galmuri_font(_size, _bold = false, _base_px = 11) {
    if (!variable_global_exists("galmuri_font_cache")) global.galmuri_font_cache = ds_map_create();
    var _px = max(8, round(_base_px * _size));
    var _key = string(_px) + (_bold ? "b" : "r");
    if (!ds_map_exists(global.galmuri_font_cache, _key)) {
        var _file = _bold ? "Galmuri11-Bold.ttf" : "Galmuri11.ttf";
        var _font = font_add(_file, _px, false, false, 32, 126);
        global.galmuri_font_cache[? _key] = _font;
    }
    return global.galmuri_font_cache[? _key];
}

function pixel_draw_text(_x, _y, _text, _bold = false) {
    pixel_draw_text_transformed(_x, _y, _text, 1, 1, 0, _bold);
}

function pixel_text_width(_text) {
    var _old = draw_get_font();
    var _font = ui_galmuri_font(1);
    if (_font == -1) return string_length(string(_text)) * 12;
    draw_set_font(_font);
    var _width = string_width(string(_text));
    draw_set_font(_old);
    return _width;
}

function pixel_score_text(_score) {
    return string(_score);
}

function pixel_draw_text_transformed(_x, _y, _text, _xscale, _yscale, _angle,
    _bold = false, _base_px = 11, _fixed_font_scale = 0) {
    var _old = draw_get_font();
    var _size = (_fixed_font_scale > 0) ? _fixed_font_scale : max(1, max(_xscale, _yscale));
    var _font = ui_galmuri_font(_size, _bold, _base_px);
    if (_font != -1) {
        draw_set_font(_font);
        draw_text_transformed(_x, _y, string(_text), _xscale / _size, _yscale / _size, _angle);
        draw_set_font(_old);
    }
}

function pixel_draw_menu_text(_x, _y, _text, _scale, _bold = false, _latin_advance = 6, _base_px = 12) {
    var _old = draw_get_font();
    var _font = ui_galmuri_font(_scale, _bold, _base_px);
    if (_font != -1) {
        draw_set_font(_font);
        var _old_halign = draw_get_halign();
        var _old_valign = draw_get_valign();
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_x, _y, string(_text));
        draw_set_halign(_old_halign);
        draw_set_valign(_old_valign);
        draw_set_font(_old);
    }
}

/// Pixel typography helpers for dynamic HUD copy.
function ui_text_px(_x, _y, _text, _scale = 1, _color = c_white, _bold = false) {
    draw_set_color(_color);
    pixel_draw_text_transformed(_x, _y, _text, _scale, _scale, 0, _bold);
}

function ui_text_fit_px(_x, _y, _text, _max_width, _scale = 1, _color = c_white) {
    var _width = max(1, pixel_text_width(_text));
    var _fit = min(_scale, max(1, floor(_max_width / _width)));
    ui_text_px(_x, _y, _text, _fit, _color);
}
