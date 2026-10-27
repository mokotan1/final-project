# Unified pixel UI atlas (2026-10-26)

**Before:** `before/` from `Build/2026-10-26-before.win` (captured earlier this session).

**After:** `after/original-title-restored/` (final title screen and Classic path), `after/final-production/` (settings, mode, story HUD), `after/result-test-state-final2/` (injected result state), `after/result-return/` (result button returns to menu), and `after/endless-final/` / `after/classic-final/` (inventory and mode HUD). Runner was placed on secondary monitor `1920,0` (1080×1920).

## Human overrides (vs Google Doc)

- Single renderer: all on-screen UI uses `spr_ui_glyph_atlas` through `pixel_draw_text_*` / `pixel_draw_menu_text` (no `font_add_sprite_ext` / mixed TTF UI).
- START / mode-select layout and `pixel_draw_menu_text` typography preserved.
- BEST reference for menu copy: **1005370** (not doc 1006370).
- This UI work did not change story 50-pair rules or score formulas. Those separately requested tasks are recorded in `docs/devlog/2026-10-26-story-break/` and `docs/devlog/2026-10-26-endless-score-cap/`.

## Changes

- Removed runtime sprite-font UI path; `lang_font_init()` only loads `global.ui_pixel_glyph_map`.
- HUD/layout widths use `pixel_text_width` instead of `string_width`.
- Korean break line fixed (`…치습니다.`); atlas extended with `·↑↓` and full Hangul scan (`tools/generate_korean_pixel_font.py` → 454 glyphs).
- `tools/runner_capture_common.ps1`: `Move-RunnerToCaptureMonitor` prefers `DISPLAY2`.
- Added `scr_ui_button` for shared five-layer L/M/S buttons, primary/secondary/selected/disabled states, hover, six-frame press and click sound. Applied it to mode, settings, result, story shop, and endless inventory/reward controls. The title screen's PLAY/SETTINGS/EXIT text and original hitboxes were restored at user request.
- The result screen test state uses score/BEST **1005370** and does not change the save file.

## Verification

- `python tools/validate_korean_font.py` — PASS (454 frames).
- `python tools/validate_presentation_resources.py` — PASS.
- Igor production compile → `Build/CushionChallenge-2026-10-26.win`, SHA256 `4F8EB2438174724B305E526645AED896EF55D0C95667E26E0A8052BE06C3B296` — PASS. The source output path is read from Igor's `Saving IFF file` log before copying.
- `python tools/test_story_fifty_round.py`, `test_story_versus.py`, `test_game_mode_rules.py`, `validate_project.py`, and `validate_presentation_resources.py` — PASS.
- Runner captures on DISPLAY2 — menu/settings/mode/story HUD, result with both button actions, endless inventory and classic HUD. The result score and story breaker cases were injected test states; the production menu/HUD captures use the normal binary.
