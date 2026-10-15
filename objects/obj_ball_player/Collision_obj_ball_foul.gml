physics_resolve_ball_collision(other);
if (physics_begin_rule_contact(other) && rules_on_foul_hit(id, other.id)) audio_sfx(global.risk_shot_active ? "snd_risk_wipe" : "snd_foul", 0.95);
