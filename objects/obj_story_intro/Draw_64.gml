if (line_index >= array_length(opening_lines)) {
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_sprite(spr_story_opening, 0, 0, 0);
    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(18, 660, 410, 708, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(241, 228, 195));
    pixel_draw_text_transformed(32, 676, "클릭 / ENTER: 시작", 1, 1, 0, false);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _prompt_alpha = 0.15 + 0.85 * (0.5 + 0.5 * sin(get_timer() * 0.000006));
    draw_set_alpha(_prompt_alpha);
    draw_set_color(c_black);
    pixel_draw_text_transformed(642, 674, "시작하려면 클릭하세요", 2, 2, 0, true);
    draw_set_color(make_color_rgb(241, 228, 195));
    pixel_draw_text_transformed(640, 672, "시작하려면 클릭하세요", 2, 2, 0, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}
var _line = opening_lines[line_index];
var _cream = make_color_rgb(241, 228, 195);
var _brass = make_color_rgb(214, 169, 82);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_sprite(spr_menu_background, 0, 0, 0);
draw_set_color(c_black);
draw_set_alpha(0.42);
draw_rectangle(0, 0, 1280, 720, false);
draw_set_alpha(1);
draw_sprite_ext(spr_assistant_dialogue, 0, 1010, 632, 0.68, 0.68, 0, c_white, 1);

draw_set_color(make_color_rgb(15, 35, 32));
draw_set_alpha(0.94);
draw_rectangle(92, 440, 1188, 682, false);
draw_set_alpha(1);
draw_set_color(_brass);
draw_rectangle(92, 440, 1188, 446, false);
pixel_draw_text_transformed(130, 473, _line.speaker, 2, 2, 0, true);
draw_set_color(_cream);
if (_line.id == "OPN-05") {
    var _break_at = string_pos(". ", _line.text);
    pixel_draw_text_transformed(130, 512, string_copy(_line.text, 1, _break_at), 2, 2, 0, false);
    pixel_draw_text_transformed(130, 555, string_delete(_line.text, 1, _break_at + 1), 2, 2, 0, false);
} else {
    pixel_draw_text_transformed(130, 535, _line.text, 2, 2, 0, false);
}
draw_set_color(_brass);
pixel_draw_text_transformed(1040, 639, string(line_index + 1) + "/" + string(array_length(opening_lines)), 1, 1, 0, false);
draw_set_color(_cream);
pixel_draw_text_transformed(130, 640, "클릭 또는 ENTER", 1, 1, 0, false);
