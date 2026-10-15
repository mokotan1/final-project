# Prototype progress record

Updated: 2026-10-13 00:00 KST

## Completed

- Cue aim guide (`/root/aim_guide`): while charging a shot, `obj_cue` draws a translucent predictive line along the actual shot direction to the first playable cushion plane when the current power can reach it, with a contact marker; friction-limited short shots end without a cushion marker and the guide does not imply a bounce path.

- Rules/application (`/root/rules`): scoring, chances, foul growth, inventory items, restart and room transitions.
- Physics/input (`/root/physics`): deterministic friction/rebounds, radius-based ball collision scan, placement validation, ball hierarchy, cushion tracking, cue aiming/charge/release.
- Presentation (`/root/ui`): 10 generated placeholder sprites, HUD with paginated inventory, result screen, 1280 x 720 result room, built-in runtime font with ASCII labels. Sprite root/frame/layer PNGs are present for GameMaker 2026.
- HUD layout (`/root/hud_layout`): compact responsive top banner keeps power, score, best, chances, gap, foul count, next reward, and transient feedback above the table rail.
- Integration (`/root/integration`): 1280 x 720 `rm_game`, exact `Instances` layer, four cushions, table at `(160,90)`, playable bounds `(210,140)-(1070,560)`, resource manifest, room order, DDD documentation, launch documentation and validators.

## Verified VM compile

Command:

```powershell
& 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe' `
  --verbose `
  '--projectool=C:\ProgramData\GameMakerStudio2-LTS2026\Plugins\@gm-tools-project-tool-win-x64\ProjectTool.exe' `
  '--runtimePath=C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23' `
  '--project=D:\final_project\final_project.yyp' '--runtime=VM' `
  '--ignorecache' '--cache=D:\final_project\Build\cache14-clean' '--temp=D:\final_project\Build\temp14-clean' `
  '--of=D:\final_project\Build\prototype.win' windows Compile
```

Result: exit code 0, `SUCCESSFUL LOAD AND LINK`, scripts/rooms/objects/final compile finished, `Igor complete.` No missing sprite or font warnings.

- Artifact: `D:\final_project\Build\final_project.win`
- Size: 125,740 bytes
- SHA-256 after the latest successful compile: `4EC3D0F2F87D6F71A14F12A873C870D9F4BF7C80CE3E89CCD1A41D8B2274A05D`

- Aim-guide build size: 128,044 bytes; SHA-256: `E98F13A1B0D96926301588B16D2D42C3524E9C4254647490F8BF788D73EDF852`

## Static validation

- `python tools\validate_project.py`: PASS, 25 resources; room composition and references valid.
- `python tools\validate_presentation_resources.py`: PASS, 10 sprites, two presentation objects, and result room.

## GUI and runner attempts

- Direct `GameMaker.exe` and Steam URL launch attempts exited quickly without a persistent IDE window; no login or external settings were changed.
- First background Igor `windows Run` invocation started Igor, but no persistent runner process/window remained.
- A diagnostic rerun initially failed because the direct IDE attempt rewrote three script paths in `final_project.yyp` to nonexistent flattened paths and added `Room1` to room order. Integration repaired those paths and restored room order to `rm_game`, `rm_result`.
- Reran Igor `windows Run` after the manifest repair. Project load, script/room/object compile, and final compile all succeeded. The runner launch failed with Windows `Win32Exception (623)` (system DLL relocation) while starting the installed `Runner.exe`. Directly starting the same runner with `-game` produced the same error. No interactive game window was opened.
- A later runner attempt reached game initialization and exposed an `obj_cushion` PreCreate crash caused by an unquoted `horizontal` object-property value. The physics agent removed that property, now initializes `orientation = "horizontal"` in `Create_0.gml`, and retains quoted `"vertical"` overrides on the left/right room instances. Cache11 recompilation after this fix passes with exit code 0.
- The next runner reported `rules_init` missing in `obj_game.Create`, and its line text still referenced the prior cushion code. ProjectTool had repeatedly normalized the manifest to `scripts/<resource>/<resource>.yy` while the files lived under custom nested physical folders. Rules and physics approved moving all three script resources to the normalized physical locations. A fresh `--ignorecache` build then compiled 41 script/function entries (`sc=41`, previously `sc=6`) and completed successfully, confirming domain/application functions are now included. GameMaker also keeps all registered rooms in `RoomOrderNodes`; `rm_game` and `rm_result` remain first and second, with unused `Room1` third.
- Direct `GameMaker.exe` and Steam URL attempts also exited without a persistent IDE window. The installed IDE/runtime are present, but GUI execution is blocked in this environment.
- After the clean script-path build, the parent observed repeatable Windows Application Error 1000 crashes: `Runner.exe` exception `0xc0000005` at offset `0x263bc0`, with no GameMaker Code Error dialog. To separate project code from the runtime environment, integration created `diagnostics/blank_runner/blank_runner.yyp`, containing one empty room and no scripts, objects, sprites, fonts, or data files. Its clean build succeeds (`sp=0, sc=0, ob=0, ro=1`) and produces `Build/blank_runner.win` (3,788 bytes; SHA-256 `E0BE975457A0D19DE77B35104F68C50F39A0AD9455B81C17BE9CB9182CECE090`). The parent will launch this control with the runtime's `windows/x64/Runner.exe`; the installation also contains an ARM64 runner, so architecture selection must be explicit.
- Live GUI verification subsequently succeeded, so the blank control launch was not needed. The GameMaker IDE project window is open under processes 12160 and 39072, and the persistent Runner process 43860 is titled `Three Cushion Challenge`. The visible game contains the table, player ball, target ball, foul balls, and HUD.
- Fresh static validation remains green: `validate_project.py` passes with 25 resources, and `validate_presentation_resources.py` passes with 10 sprites, two presentation objects, and `rm_result`.
- Passive screenshots showed the chance counter changing `4 -> 2 -> 5` and ball positions changing. Other desktop activity and a ScreenToGif overlay were present, so input provenance is uncertain. These screenshots are not evidence of an automatic chance-loss defect or of correct automatic loss behavior. No controlled gameplay input test has been completed yet.

## Exact next steps

Endless milestone rewards, queued choice gating, six-ball cap accounting, lane-aware deferred foul spawning, timed shot feedback, persistent best-score readback, and sprite-backed ball/cue rendering are implemented. Static validators and clean Igor VM compilation pass. Controlled GUI gameplay sign-off remains environment dependent; this host reports a Windows DLL relocation failure when launching Runner.exe.

The scoring rule now requires two cushion contacts before the target hit. The Windows display name is Two Cushion Challenge, and the new `two_cushion_save.ini` keeps its best score separate from the prior three-cushion record. Both static validators and a clean Igor VM compile pass for this change. Current `Build/final_project.win`: 128,044 bytes; SHA-256 `435E6A52D25448FE204E37BD3F58DF0E9A62F42D0B36CEDE870F8507D53ED7DE`.

Latest scoring revision: every target-ball hit awards 100 base points plus 100 for each cushion contacted earlier in that shot (0/1/2 cushions yield 100/200/300 points). One score is allowed per shot. The Windows display name is Cushion Challenge. Its best score uses `cushion_multiplier_save.ini`, preserving records from prior rulesets. Both static validators and a clean Igor VM compile pass. Current `Build/final_project.win`: 128,044 bytes; SHA-256 `89333083986E2A6CF31967AA0D67C6624ED933CC5BCA594B3F9F6E88947A17C8`.

Cushion hit feedback now draws a short expanding ring, rays, and +100% label at each contact, with stronger colors for later contacts; a target hit shows the resulting point payout. The effects are bounded visual state and do not change physics. Both static validators and a clean Igor VM compile pass. Current `Build/final_project.win`: 133,164 bytes; SHA-256 `43677635C0658925E60AEFE01FBCD296CB8123E941DA3D386097B78D98DA668E`. Live effect timing and readability remain to be checked in Runner.

Latest foul rule: a target hit creates provisional shot points. A foul-ball collision at any time in that shot cancels those points, animates the displayed bonus down to zero, and costs one chance; earlier completed shots retain their score. Only a clean finished shot commits points, triggers milestones, restores chances, and updates the best score. The current ruleset uses `cushion_foul_void_save.ini`, preserving older records. Both static validators and a clean Igor VM compile pass. Current `Build/final_project.win`: 136,236 bytes; SHA-256 `2B56D81918E4DCC735C7D1D89A689BA735B607D71D2B753D43983F2339DC2667`. Controlled runtime verification remains pending.

1. In the live Runner, perform a controlled-input test of ball placement, cue drag, 0/1/2-cushion scoring, foul/chance loss, inventory items, result/restart flow, and automatic chance loss when a shot stops without scoring.
2. Record any concrete gameplay defect with the visible state and triggering input before changing code.
3. If source changes, rerun both static validators and an Igor `--ignorecache` compile; record the new build hash.
