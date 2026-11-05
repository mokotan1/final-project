"""The Python mirror must not overwrite the Unity baseline when run directly."""
import shutil
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


class PythonMirrorOutputTests(unittest.TestCase):
    def test_direct_run_preserves_unity_fixture(self):
        source = Path(__file__).with_name("gm_live_physics_trace.py")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            script = root / "tools" / source.name
            script.parent.mkdir()
            shutil.copyfile(source, script)
            fixture = root / "UnityPort/Assets/Tests/Fixtures/gm_live_physics_312_15.json"
            fixture.parent.mkdir(parents=True)
            fixture.write_text("protected baseline", encoding="utf-8")
            env = os.environ.copy()
            env.update(TMP=tmp, TEMP=tmp, TMPDIR=tmp)
            result = subprocess.run([sys.executable, str(script)], capture_output=True, text=True, env=env)
            self.assertEqual("protected baseline", fixture.read_text(encoding="utf-8"))
            self.assertEqual(0, result.returncode, result.stderr)
            candidates = list(root.glob("cushion_python_trace_*.json"))
            self.assertEqual(1, len(candidates))
            candidate = json.loads(candidates[0].read_text(encoding="utf-8"))
            self.assertEqual("python_mirror_simulation", candidate["source"])
            self.assertGreater(len(candidate["frames"]), 0)


if __name__ == "__main__":
    unittest.main()
