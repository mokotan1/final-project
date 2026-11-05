var _sprite = spr_ball_foul;
var _tint = c_white;
if (object_index == obj_ball_player) _sprite = spr_ball_player;
if (object_index == obj_ball_target) _sprite = spr_ball_target;
if (object_index == obj_ball_ai) {
    _sprite = spr_ball_player;
    _tint = make_color_rgb(100, 160, 255);
}

// Layered translucent ellipses soften the contact shadow without a second shader.
var _old_alpha = draw_get_alpha();
var _old_color = draw_get_color();
var _radius = physics_radius;
draw_set_color(c_black);
draw_set_alpha(_old_alpha * 0.08);
draw_ellipse(x + 3 - _radius * 1.12, y + 5 - _radius * 0.57,
    x + 3 + _radius * 1.12, y + 5 + _radius * 0.57, false);
draw_set_alpha(_old_alpha * 0.12);
draw_ellipse(x + 3 - _radius * 0.98, y + 5 - _radius * 0.48,
    x + 3 + _radius * 0.98, y + 5 + _radius * 0.48, false);
draw_set_alpha(_old_alpha * 0.14);
draw_ellipse(x + 3 - _radius * 0.84, y + 5 - _radius * 0.39,
    x + 3 + _radius * 0.84, y + 5 + _radius * 0.39, false);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);

// Keep the moving colour sample inside the sprite's atlas cell. The shader
// preserves the original alpha so the circular outline stays fixed.
var _uv = sprite_get_uvs(_sprite, 0);
shader_set(sh_ball_scroll);
shader_set_uniform_f(ball_scroll_uniform, scroll_x, scroll_y);
shader_set_uniform_f(ball_uv_uniform, _uv[0], _uv[1], _uv[2], _uv[3]);
draw_sprite_ext(_sprite, 0, x, y, 1, 1, 0, _tint, 1);
shader_reset();
