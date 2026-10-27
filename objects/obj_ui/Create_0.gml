/// Presentation-only HUD layout (1280 x 720 GUI space).
// UI copy is drawn from spr_ui_glyph_atlas (see scr_ui_pixel_text).
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
settings_hover_resume = false;
settings_hover_main_menu = false;
ui_press_frames = 0;
ui_press_action = "";
if (!variable_global_exists("audio_enabled")) global.audio_enabled = true;
lang_init(); lang_font_init();
audio_volume_init();
settings_dragging = false;
