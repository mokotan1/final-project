# Unity GMS re-port report

Date: 2026-11-05  
Branch: `unity-gms-report`  
Source of truth: GameMaker project at repo root (`objects/`, `scripts/`, `rooms/`, `sprites/`).

## Hypothesis verification (read-only review)

| Hypothesis | Verdict | Notes |
|------------|---------|--------|
| Balls invisible due to y-down room coords used as Unity y-up | **Confirmed (root cause class)** | GMS room space is y-down; using it as Unity world y-up misplaces sprites off the table. |
| `LoadSpritesFromResources` loads `Resources/GameArt/Balls` | **Confirmed** | Sprites load; placement/coordinate layer was the main visibility issue. |
| Missing `story_versus_spawn_layout` / intro rack | **Confirmed → fixed** | `StoryVersusSpawnLayout` mirrors GMS coordinates including intro rack (640,350 / 608,350 / 624,322). |
| Missing `application_spawn_initial_balls` for endless | **Confirmed → fixed** | `ApplicationBallSpawner` ports spawn retries, foul lane offset, and `global.foul_count` count; AI ball hidden in endless. |
| Only `RollBreakBreaker` ported; missing break foul suppress + dialogue order | **Partially confirmed → improved** | GMS `story_versus_roll_break_breaker` currently returns AI only (not 50/50). Added `StoryVersusBreakRules`, `TryShowBreakAssignDialogue` (`BREAK-ASSIGN`), foul suppress on break shot. Removed incorrect OPN-01/02 on assign. |
| UI uses custom panels vs `obj_ui` Draw_64 | **Confirmed → partial fix** | `GameMakerGameplayHud` draws top-bar HUD at GMS GUI coordinates; legacy `GameHudPanel` disabled in play. Full Draw_64 (FX, inventory buttons, result) still outstanding. |
| Missing application commands, localization, stage rules, 50-round dialogue, obj_result | **Confirmed (still open)** | Story rules subset exists in `StoryVersusSession`; stage/min-cushion/foul-tax/contract not ported; `MatchResultPanel` is not `obj_result` parity. |
| Import every referenced sprite | **Tool added** | Menu: **CushionChallenge → Import Referenced GMS Sprites** (`PortReferencedSpriteImport.cs`). Run in Editor after pulling GMS art. |
| Item prices / cushion points match | **Confirmed unchanged** | Existing `GameItemRules` / score math tests retained. |

## Phase status

| Phase | Status |
|-------|--------|
| 0 — Coordinates + ball render | **Done** | `GameMakerDisplay`, `GameMakerBallVisual`, table centering, tests in `GamePlayCoordinateParityTests`. |
| 1 — Sprites | **Partial** | Core balls/table/menu in Resources; importer for all GMS-referenced sprites. |
| 2 — UI (button, pixel text, HUD, shop) | **Partial** | GMS-layout HUD + shop hint strip; no `scr_ui_button` / full pixel FX yet. |
| 3 — Spawn, break, turn order | **Mostly done** | Layouts + break assign dialogue + break foul suppress; turn banners still simplified vs GMS. |
| 4 — Endless + stage rules + items | **Partial** | Endless spawn + existing `EndlessRulesEngine`; stage rules / `scr_application_commands` not full port. |
| 5 — AI call order | **Not re-audited this pass** | `StoryAiTurnPlanner` / simulators unchanged. |
| 6 — Physics parity / golden export | **Guarded** | `ExportGolden_*` remains `[Explicit]`; baseline compare tests unchanged. |
| 7 — Result + settings | **Open** | `MatchResultPanel`, `SettingsPanel` not rebuilt from GMS objects. |

## What to test in Unity Editor

1. **Boot → Main Menu → Endless** — player + target + fouls only (no AI ball); random layout; HUD power bar top-left at GMS positions; balls visible on cloth with y-synced visuals.
2. **Story (first match / intro)** — rack at 640,350 with two fouls tangent; break assign line (“바텐더가 브레이크를 치습니다.”); AI break; foul contact during break does not penalize.
3. **Story (after intro flag cleared)** — standard layout 640,260 / 520,480 / 760,480.
4. **PlayMode tests** — `GamePlayCoordinateParityTests`, `GamePlaySceneInitializationTests` (fixed endless seed 4242).
5. **EditMode tests** — `StoryVersusSpawnLayoutTests`, `ApplicationBallSpawnerTests`, existing physics/story tests.
6. **Sprite import** — run **CushionChallenge → Import Referenced GMS Sprites**, then spot-check menu/story assets.

## Verification run (this session)

- Unity batch `unity test` blocked: Editor already open on `UnityPort` (PID 17304).
- `unity recompile` via MCP: **succeeded** after test fix.

## Files touched (summary)

- Gameplay: `GameMakerDisplay.cs`, `GameRoomController.cs`, `StoryVersusSpawnLayout.cs`, `ApplicationBallSpawner.cs`, `CueAimController.cs`
- Story: `StoryVersusSession.cs`, `StoryVersusBreakRules.cs`
- UI: `GameMakerGameplayHud.cs`
- Editor: `PortReferencedSpriteImport.cs`
- Tests: spawn/layout/coordinate/play mode initialization
