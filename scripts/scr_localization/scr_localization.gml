/// Shared language state and compact UI copy. language 0 = English, 1 = Korean.
function lang_init() {
    if (!variable_global_exists("language")) global.language = 0;
    if (!variable_global_exists("language_ready")) {
        if (file_exists("cushion_foul_void_save.ini")) {
            ini_open("cushion_foul_void_save.ini");
            global.language = ini_read_real("record", "language", global.language);
            ini_close();
        }
        global.language_ready = true;
    }
}

function lang_is_korean() { lang_init(); return global.language == 1; }
function lang_set(_korean) {
    global.language = _korean ? 1 : 0;
    ini_open("cushion_foul_void_save.ini");
    ini_write_real("record", "language", global.language);
    ini_close();
}
function lang_toggle() { lang_set(!lang_is_korean()); }

function tr(_en, _ko) { return lang_is_korean() ? _ko : _en; }
function lang_font_init() {
    if (!variable_global_exists("ui_pixel_glyph_map")) global.ui_pixel_glyph_map = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~클래식무한공이동위험샷파울제거알수없설정언어국영켜짐꺼완료재개메인뉴기회점최고록간격아템선택보상소유벤토리놓배율새게임오버종플레하세요빈곳다은쿠션마입니나를합테블을릭해으준비전에사용있때각도의승부모드순시작뒤로효과저장실패만워첫옮초역됨멈출습는량음까지０１２３４５６７８９";
    if (!variable_global_exists("ui_pixel_font") || global.ui_pixel_font == -1)
        global.ui_pixel_font = font_add_sprite_ext(spr_ui_pixel_font, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", false, 0);
    if (!variable_global_exists("ui_pixel_font_ko") || global.ui_pixel_font_ko == -1)
        global.ui_pixel_font_ko = font_add_sprite_ext(spr_ui_pixel_font_ko, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~클래식무한공이동위험샷파울제거알수없설정언어국영켜짐꺼완료재개메인뉴기회점최고록간격아템선택보상소유벤토리놓배율새게임오버종플레하세요빈곳다은쿠션마입니나를합테블을릭해으준비전에사용있때각도의승부모드순시작뒤로효과저장실패만워첫옮초역됨멈출습는량음까지０１２３４５６７８９", false, 0);
}
function lang_font() { lang_font_init(); return lang_is_korean() ? global.ui_pixel_font_ko : global.ui_pixel_font; }
function tr_mode(_mode = undefined) {
    if (is_undefined(_mode)) { game_mode_ensure(); _mode = global.game_mode; }
    return (_mode == GAME_MODE_CLASSIC) ? tr("CLASSIC", "클래식") : tr("ENDLESS", "무한");
}
function tr_item(_item) {
    switch (_item) {
        case 1: return tr("Move", "공 이동");
        case 2: return tr("Risk Shot", "위험 샷");
        case 3: return tr("Remove foul", "파울 제거");
    }
    return tr("Unknown", "알 수 없음");
}

/// Short, gameplay-facing item copy used by hover tooltips. Keep these lines
/// compact so the native 8x12 pixel atlas stays legible at 1x scale.
function tr_item_effect(_item) {
    switch (_item) {
        case 1: return tr("Place cue ball in an open spot.", "빈 곳에 공을 놓습니다.");
        case 2: return tr("Next shot: 10x per cushion.", "다음 샷은 쿠션마다 10배입니다.");
        case 3: return tr("Remove one foul ball.", "파울 공 하나를 제거합니다.");
    }
    return tr("Unknown item.", "알 수 없는 아이템입니다.");
}
function tr_item_hint(_item) {
    switch (_item) {
        case 1: return tr("Click the table to place.", "테이블을 클릭해 놓으세요.");
        case 2: return tr("Use before lining up a shot.", "샷을 준비하기 전에 사용하세요.");
        case 3: return tr("Use when a foul ball appears.", "파울 공이 있을 때 사용하세요.");
    }
    return "";
}
