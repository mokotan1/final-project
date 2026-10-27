"""Keep the active 50-pair dialogue IDs in the story JSON and CSV catalog."""
from pathlib import Path
import csv
import json

root = Path(__file__).resolve().parents[1] / "datafiles/story_dialogue"
json_path = root / "story_dialogue.json"
rows = json.loads(json_path.read_text(encoding="utf-8"))
for row in rows:
    if row["id"].startswith("EVT-CLOSE-"):
        row["direction"] = (
            "[구현] 50합 경기: 양쪽 총점>0, 차이<=200. "
            "구 검증 장면: 양쪽 300점 미만일 때만 표시. 샷 확정 후."
        )
active = [
    ("RULE-01", "match_start", "50합 한 판이야. 브레이크는 0합으로 친다."),
    ("RULE-02", "match_start", "매 합마다 손님 먼저, 그다음 내가 친다."),
    ("RULE-03", "match_start", "중간 점수로 끝나지 않아. 50합 뒤 총점으로 승부해."),
    ("TURN-25", "turn_25", "절반 지났어요. 이제부터는 점수 차가 술값보다 크게 느껴질 거예요."),
    ("TURN-40", "turn_40", "40합이에요. 남은 합마다 한 번의 실수가 바로 승패로 갈 수 있어요."),
    ("TURN-50", "turn_50", "마지막 합이에요. 이 차례 끝나면 점수판으로 승부가 납니다."),
    ("GENTLE", "gentle_shot", "이번엔 살짝 봐줄게요. 너무 긴장하지 마요."),
    ("RESULT-WIN", "result_win", "졌다. 오늘 술값은 전액 깎아줄게. 다음엔 안 봐준다."),
    ("RESULT-LOSE", "result_lose", "이번 판은 내 승리야. 술값은 원래대로 받는다."),
    ("RESULT-DRAW", "result_draw", "끝까지 팽팽했네. 술값은 반값으로 하자."),
]
by_id = {row["id"]: row for row in rows}
for dialogue_id, trigger, line in active:
    row = {
        "id": dialogue_id,
        "chapter": "공통",
        "stage": "50합 단판",
        "trigger": trigger,
        "speaker": "바텐더",
        "line": line,
        "direction": "[구현] 50합 스토리 경기에서 사용. 규칙·턴·결과 우선순위는 런타임 로직을 따른다.",
    }
    if dialogue_id in by_id:
        by_id[dialogue_id].update(row)
    else:
        rows.append(row)
json_path.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
with (root / "story_dialogue.csv").open("w", encoding="utf-8", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=["id", "chapter", "stage", "trigger", "speaker", "line", "direction"])
    writer.writeheader()
    writer.writerows(rows)
print(f"Synced {len(active)} active dialogue IDs ({len(rows)} total rows)")
