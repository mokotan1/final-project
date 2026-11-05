# Bartender recovery risk on player score loss (2026-10-29)

## Goal

When the player **loses score** and the bartender leads by at least **100,000** after that loss, schedule **once per 50-round match** a random bartender hand within the next **10 hands** (clamped to match end). On that hand the bartender buys a recovery **Risk Shot**, picks a **maximum expected risk-score** candidate, then shoots with an **8–18° intentional miss**. Settlement uses normal risk rules (foul wipe, score on hit, miss unchanged); see [2026-10-29-bartender-recovery-risk-shot-fix](../2026-10-29-bartender-recovery-risk-shot-fix/README.md) for the fix that removed forced failure in `on_shot_ended`.

## Edge cases (explicit)

| Case | Behavior |
|------|----------|
| Bartender leads ≥100k but player did not lose score on this turn | **No** schedule (e.g. lead from bartender scoring only). |
| Player loses score but gap &lt; 100k after loss | **No** schedule. |
| Player loses score via Risk Shot foul (→0), item purchase (−price), or end-of-turn score below turn-start | Schedule if gap ≥100k after loss. |
| Second qualifying loss in same match | **No** second schedule (`story_ai_recovery_risk_used` or `due_pair` already set). |
| Scheduled hand &gt; remaining pairs | `due_pair = min(max_turns, current_round + irandom(9))`. |
| Break / 0合 | No schedule while `story_break_pending`. |
| Recovery turn, no valid risk candidate | Pass turn; refund risk purchase counters (existing path). |
| Recovery shot | Always risk scoring math for candidate ranking; competitive gap heuristics **not** applied on that pick. |
| Normal bartender Risk Shot shop | Unchanged: still requires player lead ≥100k (`STORY_AI_RISK_LEAD`). |

## Before capture (pre–behavior change)

- **Attempt:** `tools/capture_story_flow.ps1` with `Build/final_project.win` (1280×720, 240 frames, `-DirectStory`).
- **Result:** **Failed** — `PrintWindow failed` twice (Runner started on capture monitor but frames could not be grabbed). No valid `before/story-flow.mp4` or PNGs from this session.
- **Baseline reference:** Existing behavior documented in [2026-10-28-ai-gap-misplay](../2026-10-28-ai-gap-misplay/README.md) (scheduled on 100k lead via `story_ai_consider_items`, not player-loss gate).

## Code changes

- `scripts/scr_story_versus/scr_story_versus.gml` — `story_versus_try_schedule_ai_recovery_risk()`; call after player shot settlement and after player item spend; track `story_player_score_at_turn_start` on player shot start.
- `scripts/scr_story_ai/scr_story_ai.gml` — `story_ai_arm_recovery_risk_if_due()`, `story_ai_pick_max_risk_shot()`; execute turn arms recovery before max-risk pick; scheduling removed from `story_ai_consider_items`.
- `tools/story_50_runtime_harness.gml` — recovery tests use player-loss schedule + max-risk pick.
- `tools/test_story_versus.py`, `tools/test_bartender_recovery_schedule.py` — static / Python schedule guards.
- `tools/bartender_recovery_capture_fixture.gml`, `tools/run_bartender_recovery_capture.ps1` — optional debug fixture (stdout, not video).

## After verification

- Independent review found that the no-candidate branch did not actually refund the purchased Risk Shot. It now restores the 3,200 points and item counter before passing; the Python checks and Igor harness build were rerun after this correction. The no-candidate refund has not been exercised in Runner.
- The Runner harness invokes settlement with test state; it does not demonstrate an actual moving shot or prove that the 8–18° deviation physically misses. **Superseded (2026-10-29):** forced failure in `on_shot_ended` was removed; harness now covers clean / foul / miss settlement flags. Visual capture limitations remain in [risk-shot-fix devlog](../2026-10-29-bartender-recovery-risk-shot-fix/README.md).
- Item purchase costs also count as player score loss for scheduling. This is an implementation interpretation, not specifically established by the player's request about losing score on a Risk Shot.

- **Runner harness:** `Build/story_50_runtime_test.win` → `after/harness_stdout.txt`  
  - `STORY_AI_RECOVERY_SCHEDULE hand=16 due=22 ai=160000 player=0`  
  - `STORY_AI_RECOVERY_RISK_TRIGGER hand=24 ai=96800 player=0`  
  - `STORY_AI_RECOVERY_RISK_FAIL … ai_after=0`  
  - `STORY50_RUNTIME_TEST PASS` (see `after/harness_stdout.txt`)
- **Python:** `test_story_versus.py`, `test_bartender_recovery_schedule.py` — ok.
- **Igor VM:** `Build/final_project.win` compile — ok (`Igor complete`).
- **Initial video/screenshot attempt:** Failed with `PrintWindow`; the later successful capture is documented below.

### Capture tooling follow-up (2026-10-29)

- **Cause:** `Process.MainWindowHandle` race → invalid HWND (`PrintWindow` / Win32 1400); DX11 Runner often returns white buffers from `PrintWindow` even when it returns true. See [`after/PRINTWINDOW_DIAGNOSIS.md`](after/PRINTWINDOW_DIAGNOSIS.md).
- **Fix:** `tools/runner_capture_common.ps1` resolves `YYGameMakerYY` and prefers screen BitBlt; `tools/capture_bartender_recovery_visual.ps1` records phase **2** fixture.
- **Genuine Runner after assets:** [`after/runner-visual/recovery-flow.mp4`](after/runner-visual/recovery-flow.mp4), [`recovery-final.png`](after/runner-visual/recovery-final.png), [`recovery-bitblt.png`](after/runner-visual/recovery-bitblt.png). Stdout: [`after/runner-visual/runner_stdout.txt`](after/runner-visual/runner_stdout.txt) (`RECOVERY_CAPTURE phase=2`, `STORY_AI_RECOVERY_RISK_TRIGGER`).
- **Before capture:** Still none from Runner; [`before/CAPTURE_FAILURE.md`](before/CAPTURE_FAILURE.md) unchanged.
- **Scope:** The final screenshot shows the shot in progress with the bartender at 176,800 points; it does not show the final score settlement. The fixture starts from an injected recovery state, so the visual does not demonstrate the player's preceding loss or scheduling delay. The 30 captured frames are encoded as a 9-second video. Screen capture requires the window to remain visible and unobstructed.

## Repro (logic)

```powershell
cd D:\final_project
python tools/test_story_versus.py
python tools/test_bartender_recovery_schedule.py
powershell -File tools/build_story_runtime_harness.ps1
& 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\windows\x64\Runner.exe' `
  -game D:\final_project\Build\story_50_runtime_test.win
# Expect STORY50_RUNTIME_TEST PASS and RECOVERY_* debug lines in stdout
```
