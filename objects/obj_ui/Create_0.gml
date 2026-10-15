/// Presentation-only HUD layout (1280 x 720 GUI space).
// English font remains the global.ui_pixel_font created by font_add_sprite_ext(spr_ui_pixel_font,...).
ui_slot_count = 6;
ui_slot_size = 64;
ui_slot_gap = 12;
ui_inventory_y = 626;
ui_inventory_page = 0;
ui_message = "";
ui_message_timer = 0;
ui_choice_active = false;
ui_slot_spin_voice = -1;
ui_slot_payout_voice = -1;
ui_slot_payout_started = false;
if (!variable_global_exists("game_settings_open")) global.game_settings_open = false;
if (!variable_global_exists("audio_enabled")) global.audio_enabled = true;
lang_init(); lang_font_init();
audio_volume_init();
settings_dragging = false;
