"""Static and logic checks for the 50-pair story match."""

from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
versus = (ROOT / "scripts/scr_story_versus/scr_story_versus.gml").read_text(encoding="utf-8")
ai = (ROOT / "scripts/scr_story_ai/scr_story_ai.gml").read_text(encoding="utf-8")
controller = (ROOT / "objects/obj_story_versus_game/Step_0.gml").read_text(encoding="utf-8")
ui_step = (ROOT / "objects/obj_ui/Step_0.gml").read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


require("#macro STORY_MAX_TURNS 50" in versus, "STORY_MAX_TURNS macro")
require("#macro STORY_SCORE_MAX 999999999" in versus, "STORY_SCORE_MAX macro")
require("global.story_completed_pairs" in versus, "completed pair counter")
require("function story_versus_is_fifty_round_match()" in versus, "fifty-round guard")
require("function story_score_add(" in versus, "saturating score add")
require("function story_risk_points_for_cushions(" in versus, "risk score helper")
require("function story_versus_finalize_fifty_round_match()" in versus, "finalize match")
init_body = versus.split("function story_versus_init()", 1)[1].split("function story_versus_stage_target()", 1)[0]
require("story_stage_index" not in init_body.split("story_versus_is_fifty_round_match()", 1)[0]
        or "if (!story_versus_is_fifty_round_match()" in init_body,
        "fifty-round init must not load stage checkpoint unconditionally")
require("if (!story_versus_is_fifty_round_match() && file_exists" in init_body,
        "checkpoint load gated off fifty-round match")
require("global.story_completed_pairs += 1" in versus, "pair increment on bartender end")
require(
    "if (story_versus_is_fifty_round_match()) return 0;" in versus,
    "stage cushions disabled in fifty-round",
)
require('"TURN-25"' in versus and '"TURN-40"' in versus and '"TURN-50"' in versus, "turn milestone ids")
require('"RULE-01"' in versus and '"RULE-0"' in versus, "opening rule sequence ids")
require('"RESULT-WIN"' in versus and '"RESULT-LOSE"' in versus and '"RESULT-DRAW"' in versus, "result ids")
require('"GENTLE"' in versus, "gentle dialogue id")
require("story_versus_input_locked()" in versus and "story_versus_input_locked()" in ui_step,
        "input lock for shop")
require("story_ai_difficulty_tier()" in ai, "AI difficulty tiers")
require("STORY_AI_SOFT_LEAD_END" in ai or "STORY_AI_SOFT_LEAD_END" in versus, "soft lead constant")
require("!story_versus_is_fifty_round_match()" in controller, "controller skips legacy chance loop")
check_over = versus.split("function story_versus_check_match_over()", 1)[1].split("function story_versus_advance_turn()", 1)[0]
require("story_versus_is_fifty_round_match()) return global.story_match_over" in check_over.replace("\n", " "),
        "fifty-round match end only via finalize flag")

_spec = importlib.util.spec_from_file_location("story_fifty_round_logic", ROOT / "tools/story_fifty_round_logic.py")
_mod = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_mod)
_mod.test_score_saturation()

print("test_story_fifty_round: ok")
