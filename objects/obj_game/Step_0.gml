if (variable_global_exists("game_settings_open") && global.game_settings_open) exit;

if (global.shot_active && physics_all_balls_stopped()) {
    rules_on_shot_ended();
}
if (global.new_best_timer > 0) global.new_best_timer--;
if (global.shot_loss_timer > 0) global.shot_loss_timer--;
if (global.shot_loss_timer <= 0) global.shot_loss_reason = "";

if (rules_items_enabled() && !global.balls_moving && global.pending_reward_choice && !global.reward_choice_open) {
    global.reward_choice_open = true;
}

while (!global.balls_moving && global.pending_foul_spawns > 0) {
    if (!global.spawn_retry_armed) break;
    if (application_spawn_ball("obj_ball_foul") == noone) {
        global.spawn_retry_armed = false;
        break;
    }
    application_take_pending_foul_spawn();
}
var _foul_object = asset_get_index("obj_ball_foul");
if (_foul_object != -1) global.foul_count = instance_number(_foul_object);

if (global.game_over_delay > 0) global.game_over_delay--;
if (global.game_over && global.game_over_delay <= 0 && !result_overlay_opened) {
    result_overlay_opened = true;
    audio_stop_sound(snd_slot_spin);
    audio_stop_sound(snd_slot_payout);
    instance_create_layer(0, 0, "Instances", obj_result);
}
