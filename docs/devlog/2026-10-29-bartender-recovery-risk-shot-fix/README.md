# Bartender recovery risk shot settlement fix (2026-10-29)

## Problem

`story_versus_on_shot_ended()` treated every recovery risk attempt as an automatic failure: it forced `shot_penalized`, zeroed AI cumulative score, and logged `STORY_AI_RECOVERY_RISK_FAIL` even when the shot state already reflected a clean score or a miss. That bypassed normal risk foul handling (`story_versus_on_foul_hit`) and fifty-round score add / miss paths.

A prior visual capture run also left `objects/obj_story_versus_game/Create_0.gml` with the recovery fixture appended; `run_bartender_recovery_capture.ps1` restored those bytes on failure, so a interrupted run could permanently duplicate fixture text in the repo.

## Fix

- **`scripts/scr_story_versus/scr_story_versus.gml`** — Remove forced recovery failure block. On an actual recovery risk shot (`story_ai_recovery_risk_pending` + `risk_shot_active` at settlement), set `story_ai_recovery_risk_used` once and clear pending; log `STORY_AI_RECOVERY_RISK_SETTLE` with foul/scored flags. Score follows existing shot flags (foul wipe, `story_score_add` on score, unchanged on miss).
- **`tools/story_50_runtime_harness.gml`** — Three settlement cases after schedule/arm checks: clean risk score (+10k), risk foul (AI already 0), miss (score unchanged); each asserts `story_ai_recovery_risk_used`.
- **`objects/obj_story_versus_game/Create_0.gml`** — Restored to init-only (three lines).
- **`tools/run_bartender_recovery_capture.ps1`** — Normalize Create to the three-line base when a fixture marker is present; inject `createBase + fixtureBlock` only (no append-to-corrupted-source).

Scheduling, max-risk pick, and 8–18° deliberate deviation in `scr_story_ai.gml` are unchanged.

## Before (pre-fix Runner evidence)

Copied from [2026-10-29-bartender-recovery-on-player-loss after/runner-visual](../2026-10-29-bartender-recovery-on-player-loss/after/runner-visual) into [`before/runner-visual-pre-fix/`](before/runner-visual-pre-fix/) **as pre-fix only**.

**Limitations (unchanged from source capture):**

- Injected phase-2 fixture; does not show player loss or scheduling delay.
- [`runner_stdout.txt`](before/runner-visual-pre-fix/runner_stdout.txt) logged `STORY_AI_RECOVERY_RISK_FAIL … ai_after=0` — settlement was forced, not physics-derived.
- Final frame is mid-shot; no trustworthy post-fix settlement comparison in that bundle.

## After verification

| Check | Result |
|-------|--------|
| `python tools/test_story_versus.py` | ok |
| `python tools/test_bartender_recovery_schedule.py` | ok |
| Igor `Build/story_50_runtime_test.win` + Runner | `STORY50_RUNTIME_TEST PASS`; three `STORY_AI_RECOVERY_RISK_SETTLE` lines (clean / foul / miss) — [`after/harness_stdout.txt`](after/harness_stdout.txt) |
| Igor `Build/final_project.win` | Igor complete |
| Post-fix visual capture phase 2 | [`after/runner-visual/`](after/runner-visual/) — stdout shows `STORY_AI_RECOVERY_RISK_SETTLE hand=16 foul=0 scored=0 ai=176800 player=0` (miss path; score not wiped) |

**Remaining gaps (honest):**

- Harness settlement tests set `global.shot_*` directly; they do not run full physics for foul vs score vs miss.
- Post-fix video still uses the debug fixture (BitBlt capture, 90 frames); it demonstrates trigger + one live miss settlement, not all three outcomes on screen.
- Max-risk pick remains sampled (6° steps); `pick_score=999999999` in capture stdout is expected for high cushion risk math.

## Repro

```powershell
cd D:\final_project
python tools/test_story_versus.py
python tools/test_bartender_recovery_schedule.py
powershell -File tools/build_story_runtime_harness.ps1
Start-Process -FilePath 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\windows\x64\Runner.exe' `
  -ArgumentList '-game','D:\final_project\Build\story_50_runtime_test.win' `
  -RedirectStandardOutput docs/devlog/2026-10-29-bartender-recovery-risk-shot-fix/after/harness_stdout.txt -Wait
powershell -File tools/capture_bartender_recovery_visual.ps1 `
  -OutputDirectory docs/devlog/2026-10-29-bartender-recovery-risk-shot-fix/after/runner-visual -RecoveryPhase 2
```
