"""Static structural validation for the GameMaker project.

This intentionally uses text checks because GameMaker .yy files permit trailing commas
and the GameMaker compiler is not guaranteed to be installed on the assessment host.
"""
from pathlib import Path
import json
import re


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "final_project.yyp"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def parse_gamemaker_json(path: Path) -> dict:
    """Parse GameMaker JSON after removing its permitted trailing commas."""
    source = path.read_text(encoding="utf-8")
    normalized = re.sub(r",\s*([}\]])", r"\1", source)
    return json.loads(normalized)


metadata_files = list(ROOT.rglob("*.yy")) + [PROJECT, ROOT / "final_project.resource_order"]
for metadata in metadata_files:
    try:
        parse_gamemaker_json(metadata)
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        raise AssertionError(f"invalid GameMaker metadata: {metadata}: {error}") from error


project_text = PROJECT.read_text(encoding="utf-8")
project_data = parse_gamemaker_json(PROJECT)
registered = re.findall(r'"id":\{"name":"([^"]+)","path":"([^"]+\.yy)"', project_text)
names = [name for name, _ in registered]
paths = [path for _, path in registered]
require(len(names) == len(set(names)), "duplicate resource name in final_project.yyp")
require(len(paths) == len(set(paths)), "duplicate resource path in final_project.yyp")
for name, path in registered:
    require((ROOT / path).is_file(), f"registered resource is missing: {name} -> {path}")
    if path.startswith("sounds/"):
        sound = parse_gamemaker_json(ROOT / path)
        require((ROOT / path).parent.joinpath(sound["soundFile"]).is_file(),
                f"sound source is missing: {path}")

discoverable = []
for category in ("sprites", "sounds", "fonts", "scripts", "objects", "rooms"):
    for path in (ROOT / category).rglob("*.yy"):
        discoverable.append(path.relative_to(ROOT).as_posix())
missing_registration = sorted(set(discoverable) - set(paths))
require(not missing_registration, f"unregistered resources: {missing_registration}")

folder_paths = {folder["folderPath"] for folder in project_data["Folders"]}
for resource_path in paths:
    resource_data = parse_gamemaker_json(ROOT / resource_path)
    parent = resource_data.get("parent")
    if parent:
        parent_path = parent["path"]
        require(parent_path == "final_project.yyp" or parent_path in folder_paths,
                f"unregistered parent folder for {resource_path}: {parent_path}")

order = re.findall(r'"roomId":\{"name":"([^"]+)","path":"([^"]+)"', project_text)
require([name for name, _ in order][:3] == ["rm_story_intro", "rm_menu", "rm_game"]
        and "rm_result" not in [name for name, _ in order],
        f"story intro, menu, and game must lead, with no separate result room: {[name for name, _ in order]}")

intro_create = (ROOT / "objects/obj_story_intro/Create_0.gml").read_text(encoding="utf-8")
require("room_goto(rm_story_ai_verify)" not in intro_create,
        "story intro Create contains a direct verification-room jump")

menu_room = (ROOT / "rooms/rm_menu/rm_menu.yy").read_text(encoding="utf-8")
require('"Width":1280' in menu_room and '"Height":720' in menu_room, "rm_menu must be 1280 x 720")
require('"name":"obj_menu"' in menu_room, "rm_menu must contain obj_menu")

game_mode = (ROOT / "scripts/scr_game_mode/scr_game_mode.gml").read_text(encoding="utf-8")
require("function rules_foul_cap()" in game_mode and "GAME_MODE_CLASSIC" in game_mode,
        "scr_game_mode must define classic/endless foul caps")

room = (ROOT / "rooms/rm_game/rm_game.yy").read_text(encoding="utf-8")
room_data = parse_gamemaker_json(ROOT / "rooms/rm_game/rm_game.yy")
require('"Width":1280' in room and '"Height":720' in room, "rm_game must be 1280 x 720")
require('"%Name":"Instances"' in room and '"name":"Instances"' in room,
        "rm_game must have an Instances layer")
for object_name in ("obj_game", "obj_cue", "obj_ui"):
    require(f'"name":"{object_name}"' in room, f"rm_game missing {object_name}")
require(room.count('"name":"obj_cushion"') == 4, "rm_game must contain four cushions")
require('"name":"spr_table"' in room and '"x":160' in room and '"y":90' in room,
        "rm_game table placement differs from the art contract")
require((ROOT / room_data["creationCodeFile"]).is_file(), "rm_game creation code is missing")
for layer in room_data["layers"]:
    for instance in layer.get("instances", []):
        if instance.get("hasCreationCode"):
            creation = ROOT / "rooms/rm_game" / f'InstanceCreationCode_{instance["name"]}.gml'
            require(creation.is_file(), f"missing instance creation code: {creation}")

room_code = (ROOT / "rooms/rm_game/RoomCreationCode.gml").read_text(encoding="utf-8")
for assignment in (
    "global.table_left = 210", "global.table_top = 140",
    "global.table_right = 1070", "global.table_bottom = 560",
):
    require(assignment in room_code, f"missing shared bound: {assignment}")

options = (ROOT / "options/main/options_main.yy").read_text(encoding="utf-8")
require('"option_game_speed":60' in options, "project must run at 60 FPS")

application = (ROOT / "scripts/scr_application_commands/scr_application_commands.gml").read_text(encoding="utf-8")
require("rules_foul_cap()" in application,
        "application spawning must respect rules_foul_cap()")
require('instance_create_layer(_x, _y, "Instances", _object)' in application,
        "application spawning must target the rm_game Instances layer")
rules_script = (ROOT / "scripts/scr_game_rules/scr_game_rules.gml").read_text(encoding="utf-8")
require("rules_foul_cap()" in rules_script, "rules must use rules_foul_cap() for foul limits")
physics = (ROOT / "scripts/scr_physics/scr_physics.gml").read_text(encoding="utf-8")
require("physics_scan_ball_collisions();" in physics and "with (obj_ball)" in physics,
        "sprite-independent ball collision scan is missing")

# Validate direct resource references in YY files. Virtual folders and texture groups
# are metadata paths and therefore intentionally excluded.
reference_pattern = re.compile(r'"path":"((?:sprites|fonts|scripts|objects|rooms)/[^"]+\.yy)"')
for yy in ROOT.rglob("*.yy"):
    text = yy.read_text(encoding="utf-8")
    for reference in reference_pattern.findall(text):
        require((ROOT / reference).is_file(), f"broken reference in {yy}: {reference}")

event_prefix = {0: "Create", 3: "Step", 6: "Mouse", 8: "Draw", 9: "KeyPress", 12: "CleanUp"}
for object_yy in (ROOT / "objects").glob("*/*.yy"):
    object_data = parse_gamemaker_json(object_yy)
    for event in object_data.get("eventList", []):
        event_type = event["eventType"]
        event_num = event["eventNum"]
        if event_type == 4:
            collision_target = event.get("collisionObjectId")
            filename = f'Collision_{collision_target["name"] if collision_target else object_yy.stem}.gml'
        else:
            require(event_type in event_prefix,
                    f"validator needs an event mapping for type {event_type} in {object_yy}")
            filename = f"{event_prefix[event_type]}_{event_num}.gml"
        require((object_yy.parent / filename).is_file(),
                f"missing event source: {object_yy.parent.name}/{filename}")

print(f"PASS: {len(registered)} resources registered; room composition and references valid")
