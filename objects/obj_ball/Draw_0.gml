var _sprite = spr_ball_foul;
if (object_index == obj_ball_player) _sprite = spr_ball_player;
if (object_index == obj_ball_target) _sprite = spr_ball_target;
draw_sprite(_sprite, 0, x, y);
