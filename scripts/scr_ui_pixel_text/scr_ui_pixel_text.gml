/// Draw glyph cells from a single texture so every character uses one sprite frame.
function pixel_draw_text(_x, _y, _text, _bold = false) {
    pixel_draw_text_transformed(_x, _y, _text, 1, 1, 0, _bold);
}

function pixel_text_width(_text) {
    var _value = string(_text);
    var _width = 0;
    for (var _i = 1; _i <= string_length(_value); _i++) {
        _width += ord(string_char_at(_value, _i)) > 127 ? 12 : 8;
    }
    return _width;
}

/// Use the Hangul atlas design for score digits on Korean screens.
function pixel_score_text(_score) {
    var _value = string(_score);
    if (!lang_is_korean()) return _value;
    var _digits = "０１２３４５６７８９";
    var _out = "";
    for (var _i = 1; _i <= string_length(_value); _i++) {
        var _char = string_char_at(_value, _i);
        var _digit = ord(_char) - ord("0");
        _out += (_digit >= 0 && _digit <= 9) ? string_char_at(_digits, _digit + 1) : _char;
    }
    return _out;
}

function pixel_draw_text_transformed(_x, _y, _text, _xscale, _yscale, _angle, _bold = false) {
    if (_angle != 0) {
        draw_text_transformed(_x, _y, _text, _xscale, _yscale, _angle);
        return;
    }
    if (!variable_global_exists("ui_pixel_glyph_map")) lang_font_init();
    var _map = global.ui_pixel_glyph_map;
    var _value = string(_text);
    var _length = string_length(_value);
    var _sx = max(1, round(_xscale));
    var _sy = max(1, round(_yscale));
    var _width = pixel_text_width(_value) * _sx;
    var _height = 14 * _sy;
    var _draw_x = _x;
    var _draw_y = _y;
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    if (_halign == fa_center) _draw_x -= _width * 0.5;
    else if (_halign == fa_right) _draw_x -= _width;
    if (_valign == fa_middle) _draw_y -= _height * 0.5;
    else if (_valign == fa_bottom) _draw_y -= _height;
    _draw_x = round(_draw_x);
    _draw_y = round(_draw_y);
    var _color = draw_get_color();
    var _alpha = draw_get_alpha();
    var _cursor_x = _draw_x;
    for (var _i = 1; _i <= _length; _i++) {
        var _char = string_char_at(_value, _i);
        var _advance = (ord(_char) > 127 ? 12 : 8) * _sx;
        if (_char != " ") {
            var _frame = string_pos(_char, _map) - 1;
            if (_frame >= 0) {
                var _source_x = (_frame mod 16) * 16 + 2;
                var _source_y = (_frame div 16) * 18 + 2;
                draw_sprite_part_ext(spr_ui_glyph_atlas, 0, _source_x, _source_y, 12, 14,
                    _cursor_x, _draw_y, _sx, _sy, _color, _alpha);
                if (_bold) draw_sprite_part_ext(spr_ui_glyph_atlas, 0, _source_x, _source_y, 12, 14,
                    _cursor_x + max(1, _sx div 2), _draw_y, _sx, _sy, _color, _alpha);
            }
        }
        _cursor_x += _advance;
    }
}

/// Compact lettering for large menu labels; other HUD text keeps its spacing.
function pixel_draw_menu_text(_x, _y, _text, _scale, _bold = false) {
    if (!variable_global_exists("ui_pixel_glyph_map")) lang_font_init();
    var _map = global.ui_pixel_glyph_map;
    var _value = string(_text);
    var _length = string_length(_value);
    var _size = max(1, round(_scale));
    var _width = 0;
    for (var _i = 1; _i <= _length; _i++) {
        var _char = string_char_at(_value, _i);
        var _advance = 6;
        if (ord(_char) > 127) _advance = 12;
        else if (_char == "I") _advance = 2;
        else if (_char == " ") _advance = 4;
        _width += _advance * _size;
    }
    var _cursor_x = round(_x - _width * 0.5);
    var _draw_y = round(_y - 7 * _size);
    var _color = draw_get_color();
    var _alpha = draw_get_alpha();
    for (var _i = 1; _i <= _length; _i++) {
        var _char = string_char_at(_value, _i);
        if (_char != " ") {
            var _frame = string_pos(_char, _map) - 1;
            if (_frame >= 0) {
                var _source_x = (_frame mod 16) * 16 + 2;
                var _source_y = (_frame div 16) * 18 + 2;
                draw_sprite_part_ext(spr_ui_glyph_atlas, 0, _source_x, _source_y, 12, 14,
                    _cursor_x, _draw_y, _size, _size, _color, _alpha);
                if (_bold) draw_sprite_part_ext(spr_ui_glyph_atlas, 0, _source_x, _source_y, 12, 14,
                    _cursor_x + 1, _draw_y, _size, _size, _color, _alpha);
            }
        }
        var _advance = 6;
        if (ord(_char) > 127) _advance = 12;
        else if (_char == "I") _advance = 2;
        else if (_char == " ") _advance = 4;
        _cursor_x += _advance * _size;
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
