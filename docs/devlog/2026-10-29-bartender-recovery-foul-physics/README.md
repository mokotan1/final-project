# Bartender recovery risk — physical foul contact (2026-10-29)

## Goal

On the scheduled recovery hand (random window within 10 AI turns after a qualifying player score loss, once per match), the bartender still buys **Risk Shot** but now **aims with the existing AI shot simulator** at a direction/power where simulated contact hits a **foul ball**, then fires that shot through `physics_shoot` with **no angle fudge** (removed 8–18° deliberate miss). Foul wipe and settlement follow **`story_versus_on_foul_hit`** / normal `story_versus_on_shot_ended` flags — no forced failure block, no teleport, no synthetic score.

If there are **no foul balls** or **no robust simulated foul path** (≥3 of 5 nearby aim samples foul in sim), the existing pass-turn + Risk Shot refund path runs unchanged.

## Before (pre-change)

Same reproducible fixture as prior recovery captures ([`tools/bartender_recovery_capture_fixture.gml`](../../../tools/bartender_recovery_capture_fixture.gml) phase 2, [`tools/capture_bartender_recovery_visual.ps1`](../../../tools/capture_bartender_recovery_visual.ps1)).

| Artifact | Path |
|----------|------|
| Video | [`before/recovery-flow.mp4`](before/recovery-flow.mp4) |
| Initial / final frames | [`before/recovery-initial.png`](before/recovery-initial.png), [`before/recovery-final.png`](before/recovery-final.png) |
| Stdout | [`before/runner_stdout.txt`](before/runner_stdout.txt) |

**Observed (before code change):** max-risk pick (`pick_score=999999999`, cushions=7), **`STORY_AI_RECOVERY_RISK_SETTLE foul=0 scored=0 ai=176800`** — intentional miss path, score unchanged. Prior narrative: [2026-10-29-bartender-recovery-on-player-loss](2026-10-29-bartender-recovery-on-player-loss/README.md), settlement fix: [2026-10-29-bartender-recovery-risk-shot-fix](2026-10-29-bartender-recovery-risk-shot-fix/README.md).

## Code changes

- **`scripts/scr_story_ai/scr_story_ai.gml`** — `story_ai_pick_recovery_foul_shot()`, `story_ai_fixture_has_recovery_foul_shot()`; recovery execute uses foul pick; no `random_range(8, 18)` on recovery; debug `STORY_AI_RECOVERY_RISK_SHOT`.
- **`tools/bartender_recovery_capture_fixture.gml`** — phase 2 logs foul pick + sim foul flag.
- **`tools/story_50_runtime_harness.gml`**, **`tools/test_story_versus.py`**, **`tools/story_ai_fixture_sim.py`** — foul-pick and fixture foul-path checks.

Scheduling (`story_versus_try_schedule_ai_recovery_risk`), once-per-match flags, and shop Risk Shot lead rule unchanged.

## After verification

| Check | Result |
|-------|--------|
| `python tools/test_story_versus.py` | ok |
| `python tools/test_bartender_recovery_schedule.py` | ok |
| `python tools/story_ai_fixture_sim.py` | ok |
| Igor `Build/story_50_runtime_test.win` + Runner | **`STORY50_RUNTIME_TEST PASS`** — [`harness_stdout.txt`](harness_stdout.txt) |
| Igor `Build/final_project.win` | Igor complete (main project compile) |
| Runner visual phase 2 | [`after/recovery-flow.mp4`](after/recovery-flow.mp4), [`after/runner_stdout.txt`](after/runner_stdout.txt) |

**Runner contact / outcome (phase 2 fixture, live physics):**

| Field | Value |
|-------|--------|
| Pick | `foul_pick=1`, `dir=36`, `power=12`, `sim_foul=1` |
| Shot log | `STORY_AI_RECOVERY_RISK_SHOT dir=36 power=12 sim_foul=1` |
| Settlement | **`STORY_AI_RECOVERY_RISK_SETTLE hand=16 foul=1 scored=0 ai=0 player=0`** |
| Turn after capture | Final frame shows **손님 차례**; its right edge is black and obscures the bartender score. The zero score is supported by Runner stdout, not that frame — [`after/recovery-final.png`](after/recovery-final.png) |

**Honest limits:**

- Capture still **injects** due hand 16 / scores; it does not show the earlier player loss or random schedule delay.
- Planner sim is an approximation; **this run** sim foul and live settle both reported foul=1 and ai→0. We do **not** claim sim always matches live physics on every layout.
- The capture is partially occluded by a black region on the right, including the bartender score on the final frame.
- This version explicitly targets a foul path and no longer chooses the maximum-scoring candidate; the visual intention of an ambitious scoring attempt is therefore not established.
- Harness foul/clean/miss settlement cases still set `global.shot_*` directly (not full physics); foul **pick** is exercised on the spawned layout in harness.

## Repro

```powershell
cd D:\final_project
python tools/test_story_versus.py
python tools/test_bartender_recovery_schedule.py
python tools/story_ai_fixture_sim.py
powershell -File tools/build_story_runtime_harness.ps1
Start-Process -FilePath 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\windows\x64\Runner.exe' `
  -ArgumentList '-game','D:\final_project\Build\story_50_runtime_test.win' `
  -RedirectStandardOutput docs/devlog/2026-10-29-bartender-recovery-foul-physics/harness_stdout.txt -Wait
powershell -File tools/capture_bartender_recovery_visual.ps1 `
  -OutputDirectory docs/devlog/2026-10-29-bartender-recovery-foul-physics/after -RecoveryPhase 2 -Frames 240
```
