if (physics_resolve_cushion_collision(other)) {
    cushion_count += 1;
    if (rules_on_cushion_hit(id, cushion_count)) audio_sfx("snd_cushion", 0.42, audio_cushion_pitch(cushion_count));
}
