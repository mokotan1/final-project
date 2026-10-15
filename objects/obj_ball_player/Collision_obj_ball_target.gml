physics_resolve_ball_collision(other);
if (physics_begin_rule_contact(other) && rules_on_target_hit(id, other.id, cushion_count) && !global.shot_penalized && !global.score_gain_fx.active) audio_sfx("snd_payout", 0.7);
