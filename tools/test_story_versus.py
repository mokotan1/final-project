"""Static checks for story versus AI verification scene."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


versus = (ROOT / "scripts/scr_story_versus/scr_story_versus.gml").read_text(encoding="utf-8")
ai = (ROOT / "scripts/scr_story_ai/scr_story_ai.gml").read_text(encoding="utf-8")
controller = (ROOT / "objects/obj_story_versus_game/Step_0.gml").read_text(encoding="utf-8")
physics = (ROOT / "scripts/scr_physics/scr_physics.gml").read_text(encoding="utf-8")
rules = (ROOT / "scripts/scr_game_rules/scr_game_rules.gml").read_text(encoding="utf-8")
yyp = (ROOT / "final_project.yyp").read_text(encoding="utf-8")
verify_room = (ROOT / "rooms/rm_story_ai_verify/rm_story_ai_verify.yy").read_text(encoding="utf-8")
menu = (ROOT / "rooms/rm_menu/rm_menu.yy").read_text(encoding="utf-8")

require("function story_versus_active()" in versus, "story versus active guard")
init_body = versus.split("function story_versus_init()", 1)[1].split("function story_versus_current_chances()", 1)[0]
require("global.score_gain_fx =" in init_body, "versus room initializes target-hit effect state")
require("story_player_chances" in versus and "story_ai_chances" in versus, "dual chances")
require("story_versus_check_match_over" in versus, "match end helper")
require("story_versus_finalize_fifty_round_match" in versus, "fifty-round finalize")
require("STORY_MAX_TURNS" in versus and "story_completed_pairs" in versus, "fifty-round state")
require("story_versus_pass_turn_no_shot" in versus, "AI pass spends chance")
require("STORY_AI_MIN_CUSHIONS" in ai and "STORY_AI_MAX_CUSHIONS" in ai, "AI cushion bounds")
require("story_ai_pick_shot" in ai and "story_ai_execute_turn" in ai, "AI pick and execute")
require("story_ai_execute_turn()" in controller, "story controller executes AI shots")
require("story_ai_gentle_turns" not in controller, "first bartender turns must not silently pass")
require("story_ai_simulate_shot_from_balls" in ai, "shared sim helper")
pair_contact = ai.split("if (_i2 == _striker || _j == _striker)", 1)[1].split("return {", 1)[0]
require('if (_other.kind == "foul") _foul = true;' in pair_contact.split('if (!_hit_target', 1)[0],
        "AI simulation tracks foul contact even after target contact")
require("_balls[_b].x += _balls[_b].vx" in ai and "_balls[_b].y += _balls[_b].vy" in ai, "sim integrates position")
require("story_ai_fixture_has_valid_candidate" in ai, "fixture candidate self-check")
require("story_versus_active()" in physics, "physics routes versus")
require("story_versus_active()" in rules, "rules delegate versus")
require('"name":"rm_story_ai_verify"' in yyp, "verify room registered")
require('"name":"obj_story_versus_game"' in verify_room, "versus controller in verify room")
require('"name":"obj_story_versus_game"' not in menu, "verify room not linked from menu")
require("rm_story_ai_verify" not in menu, "menu must not reference verify room")

import importlib.util

_spec = importlib.util.spec_from_file_location("story_ai_fixture_sim", ROOT / "tools/story_ai_fixture_sim.py")
_mod = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_mod)
_mod.main()

print("test_story_versus: ok")
