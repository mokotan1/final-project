"""Compare GM Runner trace JSON vs Unity EditMode trace JSON."""
from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UNITY_FIXTURE = ROOT / "UnityPort" / "Assets" / "Tests" / "Fixtures" / "gm_live_physics_312_15.json"
TOLERANCE = 0.06


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def run_unity_trace_json() -> dict:
    script = """
using CushionChallenge.Gameplay;
using CushionChallenge.Physics;
using UnityEngine;
var t = BilliardLiveFixtureTrace.Run(312f, 15f, BallRole.AiStriker);
Debug.Log("UNITY_TRACE_JSON_START");
Debug.Log(BilliardLiveFixtureTrace.ToJson(t));
Debug.Log("UNITY_TRACE_JSON_END");
"""
    # Prefer fresh EditMode trace via unity eval when editor is up; fall back to golden file.
    try:
        proc = subprocess.run(
            [
                "unity",
                "command",
                "eval",
                script,
                "--project-path",
                str(ROOT / "UnityPort"),
                "--format",
                "json",
            ],
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
        if proc.returncode == 0:
            for line in proc.stdout.splitlines():
                if line.startswith("{") and '"direction"' in line:
                    return json.loads(line)
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    if UNITY_FIXTURE.is_file():
        data = load_json(UNITY_FIXTURE)
        data["source"] = "unity_golden_file"
        return data
    raise SystemExit("Unity trace unavailable and no golden fixture")


def indexed_balls(balls: list[dict]) -> dict[tuple[str, int], dict]:
    """Preserve each role's occurrence order, including multiple foul balls."""
    counts: dict[str, int] = {}
    indexed = {}
    for ball in balls:
        role = ball["role"]
        index = counts.get(role, 0)
        counts[role] = index + 1
        indexed[(role, index)] = ball
    return indexed


def compare_ball(a: dict, b: dict, step: int) -> list[str]:
    diffs = []
    for field in ("x", "y", "vx", "vy"):
        av = float(a[field])
        bv = float(b[field])
        if abs(av - bv) > TOLERANCE:
            diffs.append(f"step={step} {a['role']}.{field} gm={av} unity={bv}")
    if int(a.get("lock", 0)) != int(b.get("lock", 0)):
        diffs.append(f"step={step} {a['role']}.lock gm={a.get('lock')} unity={b.get('lock')}")
    return diffs


def compare_traces(gm: dict, unity: dict) -> list[str]:
    diffs: list[str] = []
    if gm.get("direction") != unity.get("direction") or gm.get("power") != unity.get("power"):
        diffs.append("direction/power mismatch")
    g_frames = gm["frames"]
    u_frames = unity["frames"]
    if len(g_frames) != len(u_frames):
        diffs.append(f"frame count gm={len(g_frames)} unity={len(u_frames)}")
    for step in range(min(len(g_frames), len(u_frames))):
        gb = indexed_balls(g_frames[step]["balls"])
        ub = indexed_balls(u_frames[step]["balls"])
        for role in sorted(set(gb) | set(ub)):
            if role not in gb or role not in ub:
                diffs.append(f"step={step} missing role {role}")
                continue
            diffs.extend(compare_ball(gb[role], ub[role], step))
    go = gm["outcome"]
    uo = unity["outcome"]
    for key in ("cushions", "hit_target", "foul", "score"):
        if go.get(key) != uo.get(key):
            diffs.append(f"outcome.{key} gm={go.get(key)} unity={uo.get(key)}")
    return diffs


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--gm", type=Path, required=True)
    parser.add_argument("--unity", type=Path, help="Unity JSON; default run live trace")
    parser.add_argument("--report", type=Path, help="Write diff report markdown")
    args = parser.parse_args()

    gm = load_json(args.gm)
    unity = load_json(args.unity) if args.unity else run_unity_trace_json()
    diffs = compare_traces(gm, unity)

    if args.report:
        lines = [
            "# GM Runner vs Unity physics trace",
            "",
            f"- GM source: `{args.gm}` ({gm.get('source', 'unknown')})",
            f"- Unity source: {unity.get('source', args.unity or 'eval')}",
            f"- GM frames: {len(gm['frames'])}",
            f"- Unity frames: {len(unity['frames'])}",
            "",
        ]
        if not diffs:
            lines.append("**Result: MATCH** (within tolerance)")
        else:
            lines.append(f"**Result: {len(diffs)} difference(s)**")
            lines.append("")
            for d in diffs[:200]:
                lines.append(f"- {d}")
            if len(diffs) > 200:
                lines.append(f"- ... and {len(diffs) - 200} more")
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text("\n".join(lines) + "\n", encoding="utf-8")

    if diffs:
        print(f"compare_gm_unity_physics_trace: FAIL {len(diffs)} diff(s)", file=sys.stderr)
        for d in diffs[:20]:
            print(d, file=sys.stderr)
        raise SystemExit(1)
    print("compare_gm_unity_physics_trace: ok")


if __name__ == "__main__":
    main()
