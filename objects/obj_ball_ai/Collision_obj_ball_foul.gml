physics_resolve_ball_collision(other);
if (physics_begin_rule_contact(other) && !story_versus_break_foul_rules_suppressed()
    && rules_on_foul_hit(id, other))
    audio_sfx("snd_foul", 0.95);
