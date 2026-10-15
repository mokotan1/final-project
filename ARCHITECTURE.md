# DDD architecture map

The game separates gameplay decisions from GameMaker input, rendering, rooms, and instance lifecycle. The boundary is pragmatic because this is a small playable game.

| DDD role | GameMaker resources | Responsibility |
| --- | --- | --- |
| Domain: rules | `scr_game_rules` | Owns score, chances, foul count, shot state, inventory rewards, and game-over decisions. |
| Domain: physics | `scr_physics`, `obj_ball`, ball subtypes, `obj_cushion` | Owns deterministic movement, friction, table constraints, collision response, and contact notifications. |
| Application | `scr_application_commands` | Coordinates use cases such as inventory actions, legal placement, spawning, cleanup, and restart. |
| Presentation | `obj_cue`, `obj_ui`, `obj_result`, sprites | Translates mouse/keyboard input into application calls and draws gameplay feedback. |
| Composition root | `rm_game`, `rm_result`, `obj_game` | Creates the runtime graph, defines shared table coordinates, starts a run, and changes rooms. |

## Dependency direction

Presentation objects call application commands and query rule state. Application commands invoke domain helpers and create GameMaker instances. Physics reports meaningful contacts to the rules layer. The domain scripts do not draw UI or read mouse input.

The global variables are the prototype's in-memory aggregate state. `rules_init()` establishes their invariants, while rule functions are the mutation boundary. Room code only publishes the table coordinate contract; it does not implement scoring or item behavior.

## Main runtime flow

1. `rm_game` defines the cloth bounds and creates four cushion guides, `obj_game`, `obj_cue`, and `obj_ui` on the exact `Instances` layer.
2. `obj_game` initializes the rules aggregate and asks the application layer to spawn the initial balls.
3. `obj_cue` captures aim/charge input and delegates the shot to physics/rules functions.
4. Ball collisions update the shot through domain rules. Once all balls stop, the rules close the shot and award or consume chances.
5. `obj_game` spawns pending foul balls and moves to `rm_result` when the rules request game over.
6. `obj_result` displays the final/best score and invokes the restart use case.

## Extension seams

The current sprite set is used directly by the ball, cue, table, cushion, and inventory presentation objects. The current best score is loaded from and saved to `cushion_foul_void_save.ini`, with write readback verification; previous ruleset records remain in their original files. A target hit creates provisional points, and the rules commit them only when the shot stops without a foul. Additional items belong in rules plus one application command, while the HUD remains a consumer. Automated gameplay tests can call the pure rule transitions without rendering the room.
