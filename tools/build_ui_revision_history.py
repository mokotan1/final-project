"""Archive user-provided UI screenshots and build the revision record."""

from pathlib import Path
import csv
import shutil

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "ui_revision_history"
SHOTS = OUT / "screenshots"
TEMP = Path(r"C:\Users\user\AppData\Local\Temp")

# Order follows the screenshots attached to this conversation, not file timestamps.
ITEMS = [
    ("01_initial_menu_sketch.png", Path(r"C:\Users\user\Desktop\mainmenuui.png"), "초기 메인 메뉴 스케치", "TITLE, START, SETTINGS, QUIT의 기본 배치", "메뉴 구조를 먼저 정하고 실제 게임 분위기에 맞게 시각 디자인을 발전시키기 위해"),
    ("02_settings_missing_text.png", TEMP / "codex-clipboard-4877d2ba-794f-451c-8f67-a1b2817b767c.png", "설정 창 글자 누락", "설정 패널의 글자가 표시되지 않는 문제를 수정 대상으로 기록", "한국어 설정을 선택해도 조작 항목을 읽을 수 없었기 때문에"),
    ("03_settings_low_contrast.png", TEMP / "codex-clipboard-3eb78f1e-744c-4624-8c11-0ff865b2747c.png", "설정 창 낮은 대비", "글자 크기와 색 대비를 키우고 음량을 슬라이더로 조절하도록 변경", "배경과 글자가 섞여 설정값을 확인하기 어려웠기 때문에"),
    ("04_settings_glyph_corruption.png", TEMP / "codex-clipboard-46c509aa-6c16-4643-8c2a-e30e27acd3f2.png", "설정 창 글리프 깨짐", "한글 글리프의 출력과 배치를 재검토", "문자가 붉은 블록처럼 깨져 보였기 때문에"),
    ("05_settings_slider_glyphs.png", TEMP / "codex-clipboard-62d58324-e247-473f-a7b0-eeba84cd91ad.png", "슬라이더와 글자 깨짐", "슬라이더는 유지하되 항목명과 버튼 문자를 정상 출력하도록 수정", "음량 제어 자체가 있어도 항목을 식별할 수 없었기 때문에"),
    ("06_settings_text_clipping.png", TEMP / "codex-clipboard-d3f2ae4c-c905-400b-b08b-63df24d00b3f.png", "설정 글자 앞부분 잘림", "글리프 잘림을 줄이고 굵은 글씨 기능을 추가", "한국어 단어의 시작 부분이 잘려 읽기가 어려웠기 때문에"),
    ("07_game_instruction_text.png", TEMP / "codex-clipboard-1ccd063f-0080-409a-9502-8e82341c50c1.png", "게임 안내 패널", "시작 안내와 아이템 설명처럼 패널 안의 글자를 확대", "넓은 패널에 비해 안내 문구가 지나치게 작았기 때문에"),
    ("08_title_english.png", TEMP / "codex-clipboard-df2fc7e7-15ac-4c1b-9f3e-e795566275a7.png", "영어 메인 메뉴", "게임 분위기에 맞는 픽셀 서체와 버튼 배치를 정리", "초기 시안에서 발전한 화면의 읽기 순서와 일관성을 확인하기 위해"),
    ("09_title_korean.png", TEMP / "codex-clipboard-744aa940-eeaa-4a27-868e-44ff775179de.png", "한글 메인 메뉴", "설명 문구는 한글로 지원하고 버튼은 영어 표기로 통일", "버튼까지 번역하면 화면별 표기가 달라져 조작 요소의 일관성이 떨어졌기 때문에"),
    ("10_instruction_alignment.png", TEMP / "codex-clipboard-ad32e96a-ff1d-4539-bc3d-4186ce44d1ea.png", "게임 안내 문구 정렬", "시작 안내의 두 줄을 패널 중앙에 맞춤", "문장이 한쪽으로 치우쳐 보였기 때문에"),
    ("11_title_subtitle_position.png", TEMP / "codex-clipboard-da30f386-0ed1-46c9-826f-c0f962d86f04.png", "메인 메뉴 부제 위치", "한글 문구를 제거하고 CHALLENGE를 아래로 옮긴 뒤 크기를 키우고 다시 약간 위로 조정", "타이틀 아래 여백과 제목의 위계가 어색했기 때문에"),
    ("12_mode_endless_readability.png", TEMP / "codex-clipboard-cfee3acb-33fe-46b1-bdd0-47fbbcd7855e.png", "무한 모드 정보", "모드명, 설명, 최고 기록의 글자 크기와 간격을 확대", "정보 패널의 여백에 비해 글자가 너무 작았기 때문에"),
    ("13_mode_classic_readability.png", TEMP / "codex-clipboard-9744e921-a308-4286-aa42-1a485b238564.png", "클래식 모드 정보", "클래식 모드 정보에도 같은 서체 크기와 정보 위계를 적용", "모드마다 가독성이 다르면 선택 기준을 비교하기 어려웠기 때문에"),
    ("14_mode_english_score.png", TEMP / "codex-clipboard-a388adb2-a6e1-425a-8d02-07c8c6ae47e1.png", "영어 최고 점수 간격", "BEST SCORE와 숫자 사이 간격을 두고 숫자 서체를 통일", "라벨과 값이 붙어 읽히고 점수만 다른 글꼴처럼 보였기 때문에"),
    ("15_game_hud_scale.png", TEMP / "codex-clipboard-8817b26b-c105-4443-bce5-485b72b33e3e.png", "게임 HUD 글자 크기", "기회, 점수, 최고 기록 등 HUD 정보를 공간에 맞게 확대", "HUD 높이에 비해 글자가 작아 플레이 중 한눈에 보기 어려웠기 때문에"),
    ("16_result_buttons.png", TEMP / "codex-clipboard-a4fa60d5-ea45-457d-81c6-e31bc10c4612.png", "게임 오버 결과 화면", "결과를 게임 룸 위에 표시하고 버튼 글자를 스프라이트 스타일로 통일", "기존 결과 화면의 글자와 버튼 크기가 제각각이고 메인 메뉴 이동도 작동하지 않았기 때문에"),
    ("17_button_sprite_reference.png", TEMP / "codex-clipboard-6e552360-bce8-4e4c-a11e-b6ba0f46fe37.png", "START 버튼 스프라이트 기준", "결과 화면 버튼을 메뉴의 픽셀 버튼과 같은 시각 규칙으로 맞춤", "같은 게임의 버튼인데 글자 크기와 도트 밀도가 달랐기 때문에"),
    ("18_mode_text_artifacts.png", TEMP / "codex-clipboard-a1a4f560-c876-4aae-806b-3b8ac7ac83cc.png", "모드 정보 글자 얼룩", "글리프 사이의 선과 패널 위 양쪽 모서리 잘림을 수정 대상으로 기록", "정보를 읽는 데 방해가 되는 픽셀 아티팩트가 남아 있었기 때문에"),
]


def fit_image(path, max_w=5.9, max_h=2.45):
    with Image.open(path) as im:
        w, h = im.size
    scale = min(max_w / w, max_h / h)
    return Inches(w * scale), Inches(h * scale)


def add_section(doc, heading, intro, indices):
    doc.add_heading(heading, level=1)
    doc.add_paragraph(intro)
    for idx in indices:
        filename, _, label, change, reason = ITEMS[idx - 1]
        p = doc.add_paragraph(style="Heading 2")
        p.add_run(f"{idx:02d}  {label}")
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        width, height = fit_image(SHOTS / filename)
        p.add_run().add_picture(str(SHOTS / filename), width=width, height=height)
        p = doc.add_paragraph()
        p.add_run("수정 내용  ").bold = True
        p.add_run(change + "\n")
        p.add_run("수정 이유  ").bold = True
        p.add_run(reason)


def main():
    SHOTS.mkdir(parents=True, exist_ok=True)
    for filename, source, *_ in ITEMS:
        if not source.is_file():
            raise FileNotFoundError(source)
        shutil.copy2(source, SHOTS / filename)

    with (OUT / "screenshot_index.csv").open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["번호", "보관 파일", "원본 파일", "화면", "수정 내용", "수정 이유"])
        for i, (filename, source, label, change, reason) in enumerate(ITEMS, 1):
            writer.writerow([i, filename, str(source), label, change, reason])

    doc = Document()
    sec = doc.sections[0]
    sec.top_margin = Inches(0.72)
    sec.bottom_margin = Inches(0.68)
    sec.left_margin = Inches(0.82)
    sec.right_margin = Inches(0.82)
    styles = doc.styles
    normal = styles["Normal"]
    normal.font.name = "Malgun Gothic"
    normal.font.size = Pt(10.5)
    normal.paragraph_format.space_after = Pt(7)
    for name, size in [("Title", 22), ("Heading 1", 15), ("Heading 2", 11.5)]:
        st = styles[name]
        st.font.name = "Malgun Gothic"
        st.font.size = Pt(size)
        st.font.color.rgb = RGBColor(0, 0, 0)
    styles["Heading 1"].paragraph_format.space_before = Pt(15)
    styles["Heading 2"].paragraph_format.space_before = Pt(10)
    styles["Heading 2"].paragraph_format.keep_with_next = True

    doc.add_paragraph("Cushion Challenge UI 수정 기록", style="Title")
    doc.add_paragraph("사용자가 제공한 화면 캡처를 기준으로, 메인 메뉴부터 게임 결과 화면까지 무엇을 바꾸도록 요청했고 그 이유가 무엇인지 정리했다. 스크린샷 18개는 원본 PNG를 복사해 같은 폴더의 screenshots에 보관했다. 아래 내용은 화면 피드백과 프로젝트 구현을 함께 대조한 기록이며, 이미지 자체만으로 구현 완료를 입증하지 않는 항목은 수정 대상으로 표현했다.")
    doc.add_paragraph("기록 범위  메인 메뉴 · 모드 선택 · 설정과 한글 글꼴 · 게임 안내와 HUD · 결과 화면")

    add_section(doc, "1 메인 메뉴의 구조와 분위기", "손그림으로 시작한 메뉴 구조를 당구대의 초록색과 금색, 굵은 도트 글자에 맞춰 발전시켰다. 플레이, 설정, 종료를 주요 선택지로 유지했다.", [1, 8, 9, 11])
    add_section(doc, "2 설정 창과 한글 출력", "설정은 메인 메뉴와 게임 중 ESC에서 열 수 있게 했다. 음량은 슬라이더 값으로 조절하고, 한글 글리프의 누락과 잘림을 반복 점검했다.", [2, 3, 4, 5, 6])
    add_section(doc, "3 게임 안내와 HUD", "플레이 도중 바로 읽어야 하는 안내문과 점수 정보의 크기, 정렬, 서체를 맞췄다. 아이템 설명은 마우스를 올렸을 때 표시하도록 요청했다.", [7, 10, 15])
    add_section(doc, "4 모드 선택 정보", "모드 미리보기와 설명 영역을 분리하고, 선택한 모드명과 최고 점수의 가독성을 개선했다. 한국어와 영어 모두 같은 정보 위계를 따르도록 했다.", [12, 13, 14, 18])
    add_section(doc, "5 게임 결과와 버튼", "게임 오버 뒤에는 별도 결과 룸으로 전환하지 않고 게임 화면 위에 결과를 표시하도록 바꿨다. 재시작과 메인 메뉴 버튼은 기존 메뉴의 스프라이트 스타일에 맞췄다.", [16, 17])

    doc.add_heading("스크린샷 없이 전달한 수정 요청", level=1)
    doc.add_paragraph("쿠션 성공 문구와 점수 획득 연출을 더 크게, 더 오래 보이게 해 플레이 성과를 즉시 알아볼 수 있도록 요청했다. 아이템 위에 마우스를 올리면 설명을 표시해 아이템 효과를 선택 전에 이해할 수 있게 했다. 게임 스프라이트의 도트 크기에 맞춰 메뉴와 게임 룸의 글꼴을 통일했다. 조수 캐릭터 원화를 굵은 도트의 게임용 스프라이트로 조정해 프로젝트에 등록했다.")

    doc.add_heading("구현 기록에서 확인한 내용", level=1)
    doc.add_paragraph("현재 프로젝트에는 픽셀 글자 그리기와 굵게 표시하는 함수, 언어 전환, 음량 저장과 슬라이더, 게임 화면 위 결과 표시, 점수 획득 연출, 메뉴용 버튼 스프라이트가 있다. 스크린샷은 수정 요청 당시 상태를 담은 기록이므로 최신 빌드 화면과 동일하다고 단정하지 않는다.")
    doc.add_paragraph("PhotoCraft 앱 화면으로 전달된 메뉴와 모드 선택 시안 2건, Runner 화면 1건은 이 대화에 이미지로 보이지만 원본 이미지 파일 경로가 제공되지 않아 screenshots 폴더에는 포함하지 않았다. 제공된 문구와 화면 내용은 본문에 반영했다. PSD 원본과 조수 캐릭터 원화는 스크린샷 보관 대상에서 제외했다.")

    footer = sec.footer.paragraphs[0]
    footer.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    footer.add_run("Cushion Challenge UI 수정 기록")
    output = OUT / "Cushion_Challenge_UI_수정_기록.docx"
    doc.save(output)
    print(output)
    print(f"screenshots={len(ITEMS)}")


if __name__ == "__main__":
    main()
