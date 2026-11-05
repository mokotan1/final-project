physics_ball_init();
scroll_x = 0;
scroll_y = 0;
scroll_strength = 1;
ball_scroll_uniform = shader_get_uniform(sh_ball_scroll, "u_scroll");
ball_uv_uniform = shader_get_uniform(sh_ball_scroll, "u_uv_bounds");
