"""Parse GM Runner PHYSICS_LIVE_TRACE_* lines into gm_live_physics JSON."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

FRAME_RE = re.compile(r"^PHYSICS_LIVE_TRACE_FRAME (\{.*\})\s*$")
OUTCOME_RE = re.compile(r"^PHYSICS_LIVE_TRACE_OUTCOME (\{.*\})\s*$")


def parse_stdout(text: str) -> dict:
    frames = []
    outcome = None
    for line in text.splitlines():
        line = line.strip()
        m = FRAME_RE.match(line)
        if m:
            frames.append(json.loads(m.group(1)))
            continue
        m = OUTCOME_RE.match(line)
        if m:
            outcome = json.loads(m.group(1))
    if not frames:
        raise ValueError("no PHYSICS_LIVE_TRACE_FRAME lines in runner stdout")
    if outcome is None:
        raise ValueError("missing PHYSICS_LIVE_TRACE_OUTCOME in runner stdout")
    return {
        "direction": 312,
        "power": 15,
        "striker": "AiStriker",
        "source": "gamemaker_runner",
        "outcome": outcome,
        "frames": frames,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stdout", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    text = args.stdout.read_text(encoding="utf-8", errors="replace")
    data = parse_stdout(text)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(
        f"parse_physics_live_trace_stdout: ok frames={len(data['frames'])} "
        f"cushions={data['outcome']['cushions']} foul={data['outcome']['foul']}"
    )


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"parse_physics_live_trace_stdout: FAIL {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
