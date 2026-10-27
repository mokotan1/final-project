if (input_lock > 0) { input_lock -= 1; exit; }
if (!keyboard_check_pressed(vk_enter) && !keyboard_check_pressed(vk_space)
    && !mouse_check_button_pressed(mb_left)) exit;

line_index += 1;
if (line_index <= array_length(opening_lines)) exit;

ini_open("cushion_foul_void_save.ini");
ini_write_real("story", "story_intro_seen", 1);
ini_close();
global.story_intro_match = true;
room_goto(asset_get_index("rm_story_ai_verify"));
