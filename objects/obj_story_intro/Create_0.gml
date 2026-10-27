display_set_gui_size(1280, 720);
lang_init();
lang_font_init();
audio_volume_init();

global.story_intro_match = false;
var _intro_seen = 0;
var _match_done = 0;
if (file_exists("cushion_foul_void_save.ini")) {
    ini_open("cushion_foul_void_save.ini");
    _intro_seen = ini_read_real("story", "story_intro_seen", 0);
    _match_done = ini_read_real("story", "story_first_match_done", 0);
    ini_close();
}

if (_match_done > 0 || _intro_seen > 0) {
    room_goto(asset_get_index("rm_menu"));
    exit;
}

line_index = 0;
input_lock = room_speed div 4;
opening_lines = [
    { id: "OPN-01", speaker: "바텐더", text: "어서 와요. 처음 보는 얼굴이네요." },
    { id: "OPN-02", speaker: "플레이어", text: "당구대가 있네요?" },
    { id: "OPN-03", speaker: "바텐더", text: "한 판 어때요? 이기면 오늘 술값을 깎아 드릴게요." },
    { id: "OPN-04", speaker: "플레이어", text: "지면요?" },
    { id: "OPN-05", speaker: "바텐더", text: "그땐 원래 값만 받죠. 50합 뒤 점수로 승부해요. 목표 공을 맞히면 점수예요." },
    { id: "OPN-06", speaker: "플레이어", text: "좋아요. 한 판 하죠." }
];
