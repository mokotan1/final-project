"""Mirror story_ai_fixture layout to ensure at least one 2-5 cushion target hit exists."""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

BOUNDS = dict(left=210, top=140, right=1070, bottom=560)
MIN_C, MAX_C = 2, 5
POWERS = [6, 9, 12, 15, 18]
MAX_STEPS = 720
STOP = 0.08
FRICTION = 0.045
RESTITUTION = 0.96


def fixture_balls():
    return [
        {"kind": "player", "x": 380.0, "y": 350.0, "vx": 0.0, "vy": 0.0, "r": 16.0},
        {"kind": "ai", "x": 900.0, "y": 350.0, "vx": 0.0, "vy": 0.0, "r": 16.0},
        {"kind": "target", "x": 640.0, "y": 260.0, "vx": 0.0, "vy": 0.0, "r": 16.0},
        {"kind": "foul", "x": 520.0, "y": 480.0, "vx": 0.0, "vy": 0.0, "r": 16.0},
        {"kind": "foul", "x": 760.0, "y": 480.0, "vx": 0.0, "vy": 0.0, "r": 16.0},
    ]


def resolve_bounds(b, ball_index: int, striker_idx: int, state: dict) -> None:
    hit = False
    if b["x"] - b["r"] < BOUNDS["left"]:
        b["x"] = BOUNDS["left"] + b["r"]
        b["vx"] = abs(b["vx"]) * RESTITUTION
        hit = True
    elif b["x"] + b["r"] > BOUNDS["right"]:
        b["x"] = BOUNDS["right"] - b["r"]
        b["vx"] = -abs(b["vx"]) * RESTITUTION
        hit = True
    if b["y"] - b["r"] < BOUNDS["top"]:
        b["y"] = BOUNDS["top"] + b["r"]
        b["vy"] = abs(b["vy"]) * RESTITUTION
        hit = True
    elif b["y"] + b["r"] > BOUNDS["bottom"]:
        b["y"] = BOUNDS["bottom"] - b["r"]
        b["vy"] = -abs(b["vy"]) * RESTITUTION
        hit = True
    if hit and ball_index == striker_idx and not state["hit_target"] and not state["foul"]:
        state["cushions"] += 1


def pair_collide(a, b):
    dx = b["x"] - a["x"]
    dy = b["y"] - a["y"]
    dist = math.hypot(dx, dy)
    minimum = a["r"] + b["r"]
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


def simulate(direction: float, power: float) -> dict:
    balls = [dict(b) for b in fixture_balls()]
    striker = next(i for i, b in enumerate(balls) if b["kind"] == "ai")
    rad = math.radians(direction)
    balls[striker]["vx"] = math.cos(rad) * power
    balls[striker]["vy"] = math.sin(rad) * power
    state = {"cushions": 0, "hit_target": False, "foul": False}

    for _ in range(MAX_STEPS):
        moving = False
        for b in balls:
            mag = math.hypot(b["vx"], b["vy"])
            if mag > STOP:
                moving = True
                nxt = max(0.0, mag - FRICTION)
                scale = nxt / mag
                b["vx"] *= scale
                b["vy"] *= scale
            else:
                b["vx"] = b["vy"] = 0.0
            b["x"] += b["vx"]
            b["y"] += b["vy"]
        if not moving:
            break
        for i, b in enumerate(balls):
            resolve_bounds(b, i, striker, state)
        for i in range(len(balls)):
            for j in range(i + 1, len(balls)):
                if math.hypot(balls[i]["x"] - balls[j]["x"], balls[i]["y"] - balls[j]["y"]) <= balls[i]["r"] + balls[j]["r"]:
                    pair_collide(balls[i], balls[j])
                    if i == striker or j == striker:
                        other = balls[j if i == striker else i]
                        if not state["hit_target"] and not state["foul"]:
                            if other["kind"] == "target":
                                state["hit_target"] = True
                            if other["kind"] == "foul":
                                state["foul"] = True
    return state


def main() -> None:
    found = False
    for direction in range(0, 360, 6):
        for power in POWERS:
            result = simulate(direction, power)
            if result["foul"] or not result["hit_target"]:
                continue
            if MIN_C <= result["cushions"] <= MAX_C:
                found = True
                break
        if found:
            break
    if not found:
        raise AssertionError("fixture layout has no 2-5 cushion valid AI shot in python mirror sim")
    print("story_ai_fixture_sim: ok")


if __name__ == "__main__":
    main()
