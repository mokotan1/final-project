"""Keep the implemented bartender reactions identical to the dialogue sheet export."""

from pathlib import Path
import csv
import json

ROOT = Path(__file__).resolve().parents[1]
ROWS = json.loads((ROOT / "datafiles/story_dialogue/story_dialogue.json").read_text(encoding="utf-8"))
GML = (ROOT / "scripts/scr_story_versus/scr_story_versus.gml").read_text(encoding="utf-8")

reactions = [row for row in ROWS if row["id"].startswith("EVT-")]
assert len(reactions) == 15
assert len({row["id"] for row in reactions}) == len(reactions)
for row in reactions:
    assert f'"{row["id"]}"' in GML, row["id"]
    assert f'"{row["line"]}"' in GML, row["id"]

active_ids = {
    "RULE-01", "RULE-02", "RULE-03", "TURN-25", "TURN-40", "TURN-50",
    "GENTLE", "RESULT-WIN", "RESULT-LOSE", "RESULT-DRAW",
}
active = {row["id"]: row for row in ROWS if row["id"] in active_ids}
assert set(active) == active_ids
with (ROOT / "datafiles/story_dialogue/story_dialogue.csv").open(encoding="utf-8", newline="") as file:
    csv_rows = {row["id"]: row for row in csv.DictReader(file)}
for dialogue_id, row in active.items():
    assert row == csv_rows[dialogue_id], dialogue_id
    assert f'"{row["line"]}"' in GML, dialogue_id
    if not dialogue_id.startswith("RULE-0") or dialogue_id == "RULE-01":
        assert f'"{dialogue_id}"' in GML, dialogue_id
assert '"RULE-0" + string(global.story_rule_dialogue_index + 1)' in GML

assert "story_versus_react_to_shot(_shot_turn, _shot_points, _shot_foul)" in GML
assert "global.story_reaction_timer > 0" in GML
assert GML.count("_points > 1000") == 2
assert "_points >= 400" not in GML
print("PASS: 15 reactions and 10 active 50-pair dialogue lines match JSON, CSV, and GML")
