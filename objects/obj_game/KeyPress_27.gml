if (variable_global_exists("game_over") && global.game_over) exit;
if (!variable_global_exists("game_settings_open")) global.game_settings_open = false;
global.game_settings_open = !global.game_settings_open;
if (global.game_settings_open && instance_exists(obj_ui)) {
    with (obj_ui) {
        if (ui_slot_spin_voice != -1) audio_stop_sound(ui_slot_spin_voice);
        if (ui_slot_payout_voice != -1) audio_stop_sound(ui_slot_payout_voice);
        ui_slot_spin_voice = -1;
        ui_slot_payout_voice = -1;
        ui_slot_payout_started = false;
    }
}
