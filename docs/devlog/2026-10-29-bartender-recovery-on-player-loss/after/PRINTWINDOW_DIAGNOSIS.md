# PrintWindow capture failure — diagnosis (2026-10-29 session)

## Reproduction

On this PC (desktop PowerShell, `test_runner_launch.ps1` → `CanLaunch: True`):

```powershell
.\tools\capture_story_flow.ps1 -GameFile Build\final_project.win `
  -OutputDirectory docs\devlog\2026-10-29-bartender-recovery-on-player-loss\after\printwindow-repro `
  -DirectStory -Frames 3
```

**Before fix:** `PrintWindow failed` after `Runner on capture monitor: 1920,0 …`.

## Root causes (evidence)

### 1. Wrong window handle (`ERROR_INVALID_WINDOW_HANDLE` / Win32 **1400**)

Capture scripts waited on `Process.MainWindowHandle`. During startup that handle can be **non-zero but not a valid HWND** (`IsWindow` false, empty class/title, `GetClientRect` 0×0). `PrintWindow` then returns false → script throws `PrintWindow failed`.

The real GameMaker surface is a separate top-level window:

| Property | Value |
|----------|--------|
| Class | `YYGameMakerYY` |
| Title | `Cushion Challenge` |
| Client | 1280×720 (typical) |

**Fix:** resolve HWND with `EnumWindows` + process id + class `YYGameMakerYY` (`Wait-GamemakerRunnerGameWindow` in `tools/runner_capture_common.ps1`).

Diagnostic log: `after/printwindow-repro/` (manual probes); failed run output in `after/capture-fix-test/` before BitBlt-first change.

### 2. DirectX 11 — `PrintWindow` “success” but white frames

When the correct `YYGameMakerYY` handle is used, `PrintWindow` with `PW_RENDERFULLCONTENT` (flag **2**) often returns **true** while the bitmap is **solid white** (no table art). `DirectX11: Using hardware device` appears in Runner stdout.

**Fix for this project:** `Save-RunnerClientFrame -CaptureMode Auto` tries **GDI BitBlt** (`CopyFromScreen` over the client area on the capture monitor) first, then falls back to `PrintWindow`. Blank/uniform frames are rejected.

Verified game pixels: `after/runner-visual/recovery-bitblt.png`, `recovery-final.png`, `recovery-flow.mp4` (phase **2** fixture).

## Limitations

- **BitBlt** needs the Runner window **visible on the capture monitor** (secondary display in this setup). Occluded windows, RDP-only headless, or blocked desktop capture may still fail.
- **PrintWindow** remains unreliable for this DX11 Runner; do not use PrintWindow-only captures as proof of gameplay.
- **Before-change video** for this feature was never captured (`before/CAPTURE_FAILURE.md`); no pre-change Runner frames are claimed.
- Recovery **fixture** (`bartender_recovery_capture_fixture.gml`) sets table state; it is not a full 50-hand match. Stdout shows `RECOVERY_CAPTURE phase=2` and `STORY_AI_RECOVERY_RISK_TRIGGER`; final dialogue in capture matches recovery failure copy, not a full physical miss animation audit.

## Tooling changes

| File | Change |
|------|--------|
| `tools/runner_capture_common.ps1` | `Wait-GamemakerRunnerGameWindow`, `Save-RunnerClientFrame`, BitBlt-first `Auto` |
| `tools/capture_story_flow.ps1` | Uses common window resolve + `Save-RunnerClientFrame` |
| `tools/run_bartender_recovery_capture.ps1` | `-RecoveryPhase`, `-BuildOnly` |
| `tools/capture_bartender_recovery_visual.ps1` | Build + Runner video/screenshots for recovery fixture |

## Commands (after)

```powershell
cd D:\final_project
.\tools\test_runner_launch.ps1
.\tools\capture_bartender_recovery_visual.ps1 `
  -OutputDirectory docs\devlog\2026-10-29-bartender-recovery-on-player-loss\after\runner-visual `
  -RecoveryPhase 2 -Frames 60
```
