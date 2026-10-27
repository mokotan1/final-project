# Story 50-pair break (Google Doc §9.1–9.4)

**2026-10-27 변경:** 사용자 요청에 따라 브레이크 선공을 바텐더 고정으로 되돌렸다. 아래 50:50 설명과 플레이어 선공 캡처는 당시 구현 기록이다. 현재 동작은 `docs/devlog/2026-10-27-bartender-break/README.md`를 따른다.

**Baseline (before code changes):** `docs/devlog/2026-10-26-ui-and-break/before/` from `Build/2026-10-26-before.win` SHA256 `195549B2174430973797063B8246C6C28A8CA8ECFD8B46922997DBC10869766B`.

**Spec source:** Google Doc `1yA2LzJb2bP_59OyCEsbINuLTWuweKtvRNBt6SK_z8GE` section 9 items 1–4 (document contents were retrieved during this session).

## Current vs spec

| # | Spec (§9.1–9.4) | Current behavior (pre-change) |
|---|-----------------|-------------------------------|
| 1 | AI break aim: base direction toward rack with **random ±4°**; power **15–18** (random in range). | AI break uses exact aim at target center and **fixed power 18**. |
| 2 | On the **live break shot**, foul-ball contacts **bounce physically** but **no** foul penalty, VFX, or foul audio on **any** code path (collision events + physics scan). | `rules_on_foul_hit` / `story_versus_on_foul_hit` and `snd_foul` run on break like a normal shot. |
| 3 | **50/50** who breaks via a dedicated helper; show **Korean** breaker announcement for **~2 s** before play. | Match always starts **bartender break** (`story_turn = AI`, no roll). No breaker assignment line after rule dialogue. |
| 4 | **Player** break uses normal cue drag; when break ends, turn goes to the **other** side, **`completed_pairs` stays 0**, then normal **1합 손님 → 1합 바텐더** sequencing. | Only AI executes break; after break turn is **always player**. Player cannot break. |
| — | Rack layout / ball-in-hand: **undecided** in spec — keep existing 3-ball rack and cue positions. | (unchanged intent) |
| — | Do not change restitution/friction, score formulas, items, endless/classic, UI font/button assets. | (scope guard) |

## Planned implementation surface

- `scripts/scr_story_versus/scr_story_versus.gml` — breaker roll, dialogue, break turn handoff, foul suppression hook, HUD banner text.
- `scripts/scr_story_ai/scr_story_ai.gml` — AI break aim/power; only when AI is breaker.
- `scripts/scr_physics/scr_physics.gml` — skip foul **rules/audio** during break shot.
- `objects/obj_ball_player/Collision_obj_ball_foul.gml`, `objects/obj_ball_ai/Collision_obj_ball_foul.gml` — same.
- `tools/story_50_runtime_harness.gml` (+ optional break deterministic harness) — regression + labeled injected breaker.

## Verification (Runner, 2026-10-26)

- **Automated:** `story50_runtime_test.txt` → PASS (full 50-round regression with `story_test_break_breaker = AI`). `story_break_runtime_test.txt` → PASS (AI/player break end-turn + foul suppress flag; injected breaker).
- **Python:** `tools/test_story_fifty_round.py` → ok.
- **Real Runner (injected `story_test_break_breaker` via `tools/build_story_break_capture.ps1`):** Verified AI and player break clips/screenshots are in `after/ai-verified-final/` and `after/player-verified-final/`. AI break reaches player turn at 0 completed pairs; player break reaches AI follow-up at 0 completed pairs. These captures ran on secondary monitor DISPLAY2.
- **Runtime harness:** 3 AI and 3 player break trials, AI follow-up after a player break, turn handoff and break-foul suppression passed. The 50-pair harness also passed win/lose/draw, turn, score and result checks.
- **Production launch:** A fresh production build launched and captured on DISPLAY2. An earlier stale debug/build artifact caused a crash report; it is not a current production-build failure. The injected capture builds are test fixtures, not the release binary.

## After vs before

- Before: always bartender break, fixed AI aim/power, foul rules on break, post-break always player turn.
- After: 50/50 breaker + 2s Korean line, AI break ±4° and power 15–18, break fouls physics-only, post-break opposite side with `completed_pairs` still 0 then normal pair alternation.
