"""Compare saved GM Runner and Unity traces; this does not execute either game."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GM = ROOT / "UnityPort/Assets/Tests/Fixtures/gm_live_physics_312_15_gm_runner.json"
UNITY = ROOT / "UnityPort/Assets/Tests/Fixtures/gm_live_physics_312_15.json"


def main() -> None:
    if not GM.is_file():
        raise SystemExit(f"missing GM runner golden: {GM} — run tools/run_physics_live_trace.ps1")
    if not UNITY.is_file():
        raise SystemExit(f"missing Unity baseline: {UNITY} — export and review a candidate before replacing it")

    proc = subprocess.run(
        [
            sys.executable,
            str(ROOT / "tools/compare_gm_unity_physics_trace.py"),
            "--gm",
            str(GM),
            "--unity",
            str(UNITY),
            "--report",
            str(ROOT / "docs/devlog/2026-11-03-unity-live-gm-parity/after/gm-vs-unity-trace-diff.md"),
        ],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        print(proc.stdout)
        print(proc.stderr, file=sys.stderr)
        raise SystemExit(proc.returncode)
    print("test_gm_runner_unity_parity: ok (saved GM Runner and Unity traces; no new runtime measurement)")


if __name__ == "__main__":
    main()
