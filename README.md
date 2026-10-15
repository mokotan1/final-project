# Cushion Challenge

This repository is a GameMaker 2026 endless high-score billiards game based on the supplied design documents. It includes scoring, milestone rewards, foul-ball pressure, inventory choices, persistent best score, HUD feedback, and a result screen.

The run starts with 3 chances and 1 foul ball. Hitting the target ball earns a provisional 100 points doubled for each cushion the player ball hit before the target (0 cushions = 100, 1 = 200, 2 = 400, 3 = 800). Consecutive clean target hits with no prior cushion score 100, 100, 70, 40, 10, then zero, never below zero; a cushioned hit, miss, or foul resets that streak. The points become final when the shot stops without a foul; a clean scoring shot restores chances to 3. Touching any foul ball voids the entire shot's points, even after the target hit, and costs one chance. A non-scoring shot also costs one chance. Item rewards use a separate meter: a clean target hit earns 0 for no cushion, 1 for one cushion, or 2 for two or more cushions; a successful Risk Shot adds 1 more. A normal foul-ball collision earns 1 item meter unit despite awarding no score and costing a chance. A Risk Shot foul still clears the meter to zero. The first three item goals require 3, 5, and 7 meter units for Move, Remove foul (one foul ball), and Risk Shot respectively; each later choice reward requires 8 units. At most one item is granted per scoring shot, with leftover meter carried forward. Risk Shot applies to the next shot: its target reward is 100 times ten for each prior cushion (1 = 1,000, 2 = 10,000); with no cushion, it follows the zero-cushion streak rule. A foul collision during that shot resets the current cumulative score and item meter to zero while preserving reward choice progression, owned items, and the best score. Foul balls cap at six, and unsafe spawns retry after a later shot. This ruleset uses `cushion_foul_void_save.ini` so prior records remain intact.

Each cushion hit displays a brief escalating ring and the accumulated score multiplier. A target hit displays the final payout for that shot. These are visual feedback effects; they do not alter the collision or scoring rules.

## Run in GameMaker

1. Open `final_project.yyp` in GameMaker 2026.0 or a compatible newer IDE/runtime.
2. Select the default configuration and press **Run** (F6). `rm_menu` is the first room; pick **Endless** or **Classic**, then play in `rm_game` and `rm_result`.

The project runs at 60 FPS in a 1280 x 720 room.

## Verified command-line compile

The installed LTS 2026 runtime can compile the VM data file directly. PowerShell:

```powershell
& 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe' `
  '--projectool=C:\ProgramData\GameMakerStudio2-LTS2026\Plugins\@gm-tools-project-tool-win-x64\ProjectTool.exe' `
  '--runtimePath=C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23' `
  '--project=D:\final_project\final_project.yyp' '--runtime=VM' `
  '--cache=D:\final_project\Build\cache' '--temp=D:\final_project\Build\temp' `
  '--of=D:\final_project\Build\prototype.win' windows Compile
```

Igor writes the compiled data as `Build/final_project.win`. Supplying `--projectool` is required for this installation; without it Igor cannot start its project conversion process.

## Controls

- Move the mouse to aim.
- Hold the left mouse button to charge, then release to shoot.
- **Classic** mode removes items and caps foul balls at four; **Endless** keeps the full item loop with a six-foul cap.
- Click an inventory slot to use its item (Endless only). The UI arrows or mouse wheel page through inventories longer than six slots.
- Press **R** to restart the current run.
- On the result screen, click or press Enter/Space to play again.

## Static validation

When GameMaker is unavailable, run:

```powershell
python tools/validate_project.py
python tools/validate_presentation_resources.py
python tools/test_game_mode_rules.py
python tools/validate_modes.py
```

These checks validate registration, file references, room order and dimensions, required instances and layer names, shared table bounds, object event files, presentation assets, and the 60 FPS option. They do not compile GML; open and run the project in GameMaker for compiler and runtime validation.

## Table coordinates

`spr_table` is placed at `(160, 90)`. The playable cloth is `(210, 140)` through `(1070, 560)`. `rm_game` publishes those values as `global.table_left`, `global.table_top`, `global.table_right`, and `global.table_bottom` before instances are created.
