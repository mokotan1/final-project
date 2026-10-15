"""Create a visually checkable PDF from the archived UI screenshots."""

from pathlib import Path

from PIL import Image as PILImage
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, KeepTogether

from build_ui_revision_history import ITEMS, OUT, SHOTS


FONT = Path(r"C:\Windows\Fonts\malgun.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\malgunbd.ttf")
pdfmetrics.registerFont(TTFont("Malgun", str(FONT)))
pdfmetrics.registerFont(TTFont("MalgunBold", str(FONT_BOLD)))

styles = {
    "title": ParagraphStyle("title", fontName="MalgunBold", fontSize=20, leading=27, spaceAfter=15),
    "intro": ParagraphStyle("intro", fontName="Malgun", fontSize=10, leading=16, spaceAfter=12),
    "h1": ParagraphStyle("h1", fontName="MalgunBold", fontSize=13.5, leading=20, spaceBefore=12, spaceAfter=8),
    "h2": ParagraphStyle("h2", fontName="MalgunBold", fontSize=10.5, leading=16, spaceBefore=11, spaceAfter=6),
    "body": ParagraphStyle("body", fontName="Malgun", fontSize=9.2, leading=14.2, spaceAfter=9),
    "small": ParagraphStyle("small", fontName="Malgun", fontSize=8.5, leading=13, textColor=colors.HexColor("#555555")),
}


def pic(path: Path):
    with PILImage.open(path) as im:
        w, h = im.size
    scale = min(167 * mm / w, 61 * mm / h)
    return Image(str(path), width=w * scale, height=h * scale, hAlign="CENTER")


def section(story, heading, intro, indices):
    story.append(Paragraph(heading, styles["h1"]))
    story.append(Paragraph(intro, styles["intro"]))
    for idx in indices:
        filename, _, label, change, reason = ITEMS[idx - 1]
        block = [
            Paragraph(f"{idx:02d}  {label}", styles["h2"]),
            pic(SHOTS / filename),
            Spacer(1, 3 * mm),
            Paragraph(f"<b>수정 내용</b>  {change}<br/><b>수정 이유</b>  {reason}", styles["body"]),
        ]
        story.append(KeepTogether(block))


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Malgun", 8)
    canvas.setFillColor(colors.HexColor("#666666"))
    canvas.drawString(20 * mm, 13 * mm, "Cushion Challenge UI 수정 기록")
    canvas.drawRightString(A4[0] - 20 * mm, 13 * mm, str(doc.page))
    canvas.restoreState()


def main():
    target = OUT / "Cushion_Challenge_UI_수정_기록.pdf"
    pdf = SimpleDocTemplate(
        str(target), pagesize=A4, leftMargin=20 * mm, rightMargin=20 * mm,
        topMargin=18 * mm, bottomMargin=20 * mm, title="Cushion Challenge UI 수정 기록",
    )
    story = [
        Paragraph("Cushion Challenge UI 수정 기록", styles["title"]),
        Paragraph("사용자가 제공한 화면 캡처를 기준으로 메인 메뉴부터 결과 화면까지 무엇을 바꾸도록 요청했고, 왜 바꾸었는지 정리했다. PNG 18개는 원본을 복사하여 같은 폴더의 screenshots에 보관했다. 스크린샷은 피드백 당시 상태를 보여 주며, 최신 빌드가 동일하다는 뜻은 아니다.", styles["intro"]),
        Paragraph("기록 범위  메인 메뉴 · 모드 선택 · 설정과 한글 글꼴 · 게임 안내와 HUD · 결과 화면", styles["small"]),
    ]
    section(story, "1 메인 메뉴의 구조와 분위기", "손그림으로 시작한 메뉴 구조를 당구대의 초록색과 금색, 굵은 도트 글자에 맞춰 발전시켰다.", [1, 8, 9, 11])
    section(story, "2 설정 창과 한글 출력", "설정은 메인 메뉴와 게임 중 ESC에서 열 수 있게 했다. 음량은 슬라이더로 조절하고 한글 글리프의 누락과 잘림을 점검했다.", [2, 3, 4, 5, 6])
    section(story, "3 게임 안내와 HUD", "플레이 도중 바로 읽어야 하는 안내문과 점수 정보의 크기, 정렬, 서체를 맞췄다. 아이템 설명은 마우스를 올렸을 때 표시하도록 요청했다.", [7, 10, 15])
    section(story, "4 모드 선택 정보", "모드 미리보기와 설명 영역을 분리하고, 선택한 모드명과 최고 점수의 가독성을 개선했다. 한국어와 영어 모두 같은 정보 위계를 따르도록 했다.", [12, 13, 14, 18])
    section(story, "5 게임 결과와 버튼", "게임 오버 뒤에는 별도 결과 룸으로 전환하지 않고 게임 화면 위에 결과를 표시하도록 바꿨다. 버튼은 기존 메뉴의 스프라이트 스타일에 맞췄다.", [16, 17])
    story += [
        Paragraph("스크린샷 없이 전달한 수정 요청", styles["h1"]),
        Paragraph("쿠션 성공 문구와 점수 획득 연출을 더 크게, 더 오래 보이게 해 플레이 성과를 즉시 알아볼 수 있도록 요청했다. 아이템 위에 마우스를 올리면 설명을 표시해 선택 전에 효과를 이해할 수 있게 했다. 게임 스프라이트의 도트 크기에 맞춰 메뉴와 게임 룸의 글꼴을 통일했다. 조수 캐릭터 원화를 굵은 도트의 게임용 스프라이트로 조정해 프로젝트에 등록했다.", styles["body"]),
        Paragraph("구현 기록에서 확인한 내용", styles["h1"]),
        Paragraph("현재 프로젝트에는 픽셀 글자와 굵게 표시하는 함수, 언어 전환, 음량 저장과 슬라이더, 게임 화면 위 결과 표시, 점수 획득 연출, 메뉴 버튼 스프라이트가 있다. 이 문서의 각 그림은 피드백 당시의 화면이며 완성 상태를 입증하는 자료는 아니다.", styles["body"]),
        Paragraph("PhotoCraft에서 전달된 메뉴·모드 선택 시안과 Runner 화면은 대화에서 확인했지만 원본 이미지 파일 경로가 없어 폴더에 복사하지 못했다. PSD와 조수 캐릭터 원화는 화면 캡처 보관 대상에서 제외했다.", styles["body"]),
    ]
    pdf.build(story, onFirstPage=footer, onLaterPages=footer)
    print(target)


if __name__ == "__main__":
    main()
