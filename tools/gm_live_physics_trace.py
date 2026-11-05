"""Python simulation of the physics; its output is not a GameMaker Runner trace."""
from __future__ import annotations

import json
import math
import os
import tempfile
from pathlib import Path

BOUNDS = dict(left=210, top=140, right=1070, bottom=560)
R = 16.0
FRICTION = 0.045
STOP = 0.08
RESTITUTION = 0.96
CUSHION_LOCK = 3
PAIR_LOCK = 3
MAX_STEPS = 720
RULE_LOCK = 30

# TableCushionLayout / rm_game segments (center, scale) -> world AABB
SEGMENTS = [
    ("horizontal", 640, 140, 13.4375, 1.0),
    ("horizontal", 640, 560, 13.4375, 1.0),
    ("vertical", 210, 350, 6.5625, 1.0),
    ("vertical", 1070, 350, 6.5625, 1.0),
]
SPRITE_W, SPRITE_H = 64.0, 32.0


def segment_bounds(orientation: str, cx: float, cy: float, sx: float, sy: float):
    w = SPRITE_W * sx
    h = SPRITE_H * sy
    if orientation == "vertical":
        w, h = h, w
    return cx - w * 0.5, cy - h * 0.5, cx + w * 0.5, cy + h * 0.5


SEG_RECTS = [segment_bounds(o, cx, cy, sx, sy) for o, cx, cy, sx, sy in SEGMENTS]


def fixture_balls():
    # Same order as StoryAiSimulator.FixtureLayout / Unity probe.
    return [
        {"role": "Player", "id": 1, "x": 380.0, "y": 350.0, "vx": 0.0, "vy": 0.0},
        {"role": "AiStriker", "id": 2, "x": 900.0, "y": 350.0, "vx": 0.0, "vy": 0.0},
        {"role": "Target", "id": 3, "x": 640.0, "y": 260.0, "vx": 0.0, "vy": 0.0},
        {"role": "Foul", "id": 4, "x": 520.0, "y": 480.0, "vx": 0.0, "vy": 0.0},
        {"role": "Foul", "id": 5, "x": 760.0, "y": 480.0, "vx": 0.0, "vy": 0.0},
    ]


def length_dir(deg: float, power: float):
    rad = math.radians(deg)
    return math.cos(rad) * power, -math.sin(rad) * power


def circle_overlaps_rect(cx, cy, radius, rect):
    x0, y0, x1, y1 = rect
    closest_x = min(max(cx, x0), x1)
    closest_y = min(max(cy, y0), y1)
    dx = cx - closest_x
    dy = cy - closest_y
    return dx * dx + dy * dy <= radius * radius


def resolve_bounds(b, events):
    hit = False
    counted = False
    if b["x"] - R < BOUNDS["left"]:
        b["x"] = BOUNDS["left"] + R
        b["vx"] = abs(b["vx"]) * RESTITUTION
        hit = True
    elif b["x"] + R > BOUNDS["right"]:
        b["x"] = BOUNDS["right"] - R
        b["vx"] = -abs(b["vx"]) * RESTITUTION
        hit = True
    if b["y"] - R < BOUNDS["top"]:
        b["y"] = BOUNDS["top"] + R
        b["vy"] = abs(b["vy"]) * RESTITUTION
        hit = True
    elif b["y"] + R > BOUNDS["bottom"]:
        b["y"] = BOUNDS["bottom"] - R
        b["vy"] = -abs(b["vy"]) * RESTITUTION
        hit = True
    if hit and b["cushion_lock"] <= 0:
        b["cushion_lock"] = CUSHION_LOCK
        counted = True
        events.append("cloth_cushion")
    return counted


def resolve_segment(b, orientation, events):
    if b["cushion_lock"] > 0:
        return
    if orientation == "horizontal":
        b["vy"] = -b["vy"] * RESTITUTION
    else:
        b["vx"] = -b["vx"] * RESTITUTION
    b["cushion_lock"] = CUSHION_LOCK
    events.append("segment_cushion")


def pair_collide(a, b, pair_locks, events):
    if pair_locks[a["id"]].get(b["id"], 0) > 0:
        return
    dx = b["x"] - a["x"]
    dy = b["y"] - a["y"]
    dist = math.hypot(dx, dy)
    minimum = R + R
    if dist >= minimum:
        return
    if dist <= 0:
        dx, dy, dist = 1.0, 0.0, 1.0
    nx, ny = dx / dist, dy / dist
    overlap = minimum - dist
    a["x"] -= nx * overlap * 0.5
    a["y"] -= ny * overlap * 0.5
    b["x"] += nx * overlap * 0.5
    b["y"] += ny * overlap * 0.5
    rel = (a["vx"] - b["vx"]) * nx + (a["vy"] - b["vy"]) * ny
    if rel <= 0:
        return
    imp = rel * RESTITUTION
    a["vx"] -= imp * nx
    a["vy"] -= imp * ny
    b["vx"] += imp * nx
    b["vy"] += imp * ny
    pair_locks[a["id"]][b["id"]] = PAIR_LOCK
    pair_locks[b["id"]][a["id"]] = PAIR_LOCK
    events.append("ball")


def simulate(direction: float, power: float) -> dict:
    balls = fixture_balls()
    striker = next(b for b in balls if b["role"] == "AiStriker")
    vx, vy = length_dir(direction, power)
    striker["vx"], striker["vy"] = vx, vy
    for b in balls:
        b["cushion_lock"] = 0
    pair_locks: dict[int, dict[int, int]] = {b["id"]: {} for b in balls}
    rule_locks: dict[int, int] = {}
    cushions = 0
    hit_target = False
    foul = False
    scored = False
    frames = []

    for step in range(MAX_STEPS):
        for k in list(rule_locks.keys()):
            rule_locks[k] -= 1
            if rule_locks[k] <= 0:
                del rule_locks[k]

        events: list[str] = []
        ordered = sorted(balls, key=lambda x: x["id"])

        for b in ordered:
            if b["cushion_lock"] > 0:
                b["cushion_lock"] -= 1
            locks = pair_locks[b["id"]]
            for k in list(locks.keys()):
                locks[k] -= 1
                if locks[k] <= 0:
                    del locks[k]

            mag = math.hypot(b["vx"], b["vy"])
            if mag > STOP:
                nxt = max(0.0, mag - FRICTION)
                scale = nxt / mag
                b["vx"] *= scale
                b["vy"] *= scale
            else:
                b["vx"] = b["vy"] = 0.0

            if resolve_bounds(b, events) and b["role"] == "AiStriker" and not scored and not foul:
                cushions += 1

            for other in ordered:
                if other["id"] == b["id"]:
                    continue
                if math.hypot(b["x"] - other["x"], b["y"] - other["y"]) <= R + R:
                    pair_collide(b, other, pair_locks, events)
                    if b["role"] == "AiStriker" or other["role"] == "AiStriker":
                        striker_ball = b if b["role"] == "AiStriker" else other
                        other_ball = other if striker_ball is b else b
                        key = other_ball["id"]
                        if rule_locks.get(key, 0) <= 0:
                            rule_locks[key] = RULE_LOCK
                            if other_ball["role"] == "Foul":
                                foul = True
                            if not foul and other_ball["role"] == "Target":
                                hit_target = True
                                scored = True

        for b in ordered:
            if b["cushion_lock"] > 0:
                continue
            for (orientation, *_), rect in zip(SEGMENTS, SEG_RECTS):
                if circle_overlaps_rect(b["x"], b["y"], R, rect):
                    resolve_segment(b, orientation, events)
                    break

        for b in ordered:
            b["x"] += b["vx"]
            b["y"] += b["vy"]

        frame_balls = [
            {
                "role": b["role"],
                "x": round(b["x"], 4),
                "y": round(b["y"], 4),
                "vx": round(b["vx"], 4),
                "vy": round(b["vy"], 4),
                "lock": b["cushion_lock"],
            }
            for b in balls
        ]
        frames.append({"step": step, "events": events, "balls": frame_balls})

        moving = any(math.hypot(b["vx"], b["vy"]) > STOP for b in balls)
        if not moving:
            break

    score = 0

    return {
        "direction": direction,
        "power": power,
        "striker": "AiStriker",
        "outcome": {
            "cushions": cushions,
            "hit_target": hit_target,
            "foul": foul,
            "score": score,
        },
        "frames": frames,
    }


def write_candidate(direction: float, power: float) -> Path:
    data = simulate(direction, power)
    data["source"] = "python_mirror_simulation"
    fd, name = tempfile.mkstemp(prefix="cushion_python_trace_", suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as output:
        json.dump(data, output, indent=2)
    return Path(name)


def main() -> None:
    path = write_candidate(312, 15)
    data = json.loads(path.read_text(encoding="utf-8"))
    print(f"gm_live_physics_trace: Python simulation candidate {path} outcome={data['outcome']}")


if __name__ == "__main__":
    main()
