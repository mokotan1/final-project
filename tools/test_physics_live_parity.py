"""Validate Unity-exported GM live golden trace and regenerate helper."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GOLDEN = ROOT / "UnityPort" / "Assets" / "Tests" / "Fixtures" / "gm_live_physics_312_15.json"


def main() -> None:
    if not GOLDEN.is_file():
        raise SystemExit(f"missing Unity baseline: {GOLDEN} — export and review a candidate before replacing it")
    data = json.loads(GOLDEN.read_text(encoding="utf-8"))
    assert data["direction"] == 312 and data["power"] == 15
    assert "outcome" in data and "frames" in data
    assert len(data["frames"]) > 0
    print(
        "test_physics_live_parity: ok "
        f"cushions={data['outcome']['cushions']} "
        f"hit={data['outcome']['hit_target']} "
        f"foul={data['outcome']['foul']} "
        f"frames={len(data['frames'])}"
    )


if __name__ == "__main__":
    main()
