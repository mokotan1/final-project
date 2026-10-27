# Story Turn Tempo Implementation Plan

> **For agentic workers:** Implement and verify each task in the current checkout. Preserve the before capture before changing gameplay code.

**Goal:** Let story dialogue remain visible while the next turn becomes playable in roughly one second after balls stop.

**Architecture:** Separate nonblocking reaction/help dialogue from required 50-pair opening instructions and stage-clear confirmation. The turn banner and AI delay control only brief visual turn handoff; dialogue timers continue independently. Keep the existing dialogue and banner boxes in their separate vertical bands.

**Tech Stack:** GameMaker GML, Igor VM compiler, Runner capture scripts.

**Spec:** Google Doc `1NtR0oEYix1ETj-tZ16G6O3I1B17HD1dU1FK29iMCxwg` (2026-10-27), with the current source at `D:\final_project` taking precedence over the document's stale path note.

## Global Constraints

- Preserve stage-clear Enter/click confirmation, initial 50-pair rules and breaker announcement order, pass-turn semantics, and 50-pair counting.
- Do not change physics, scoring, risk multipliers, break procedure, fonts, or cue hit area.
- Capture before/after on the secondary monitor under `docs/devlog/2026-10-27-story-turn-tempo/`.

## Review Focus

- Initial rule and breaker lines must finish before the AI break.
- H help and reaction lines must not lock an otherwise playable turn.
- Stage clear must still block shots and await Enter/click.
- Reaction dialogue and turn banner must remain legible together; pass/no-chances text must not collide.
- AI must start within about one second after a settled shot without waiting for dialogue expiry.

### Task 1: Turn gates and timing

- [x] Add a narrow opening-dialogue gate in `scripts/scr_story_versus/scr_story_versus.gml`; make `story_versus_input_locked()` depend on it, stage clear, and banner only.
- [x] In `objects/obj_story_versus_game/Step_0.gml`, start the banner after balls stop even while reaction/help dialogue continues, shorten banner to 0.5 s, and AI wait to 0.5 s.
- [x] In `scripts/scr_story_ai/scr_story_ai.gml`, remove the redundant reaction/dialogue gate while retaining stage-clear protection.
- [x] Run a Runner harness for opening lock, reaction/help unlock, stage clear, banner duration, AI delay, and 50-pair turn order.

### Task 2: Overlays and evidence

- [x] Update `scripts/scr_story_versus/scr_story_versus.gml` banner fade for 0.5 s, give help explicit display priority, and place pass/no-chances text clear of the dialogue and banner.
- [x] Build the production `.win`, capture the same story interaction after the change, compare before/after, and record measured turn latency and changed files in the devlog.

