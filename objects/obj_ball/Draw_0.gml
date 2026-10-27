var _sprite = spr_ball_foul;
if (object_index == obj_ball_player) _sprite = spr_ball_player;
if (object_index == obj_ball_target) _sprite = spr_ball_target;
if (object_index == obj_ball_ai) {
    draw_sprite_ext(spr_ball_player, 0, x, y, 1, 1, 0, make_color_rgb(100, 160, 255), 1);
    exit;
}
draw_sprite(_sprite, 0, x, y);
