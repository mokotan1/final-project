"""Check UI copy against the bundled Galmuri11 font character maps."""

from pathlib import Path
import re
from fontTools.ttLib import TTFont


ROOT = Path(__file__).resolve().parents[1]
SOURCES = [*ROOT.glob("scripts/**/*.gml"), *ROOT.glob("objects/**/*.gml"),
           ROOT / "datafiles/story_dialogue/story_dialogue.json"]
TEXT = "".join(
    "".join(re.findall(r'"(?:\\.|[^"\\])*"', path.read_text(encoding="utf-8-sig", errors="ignore")))
    if path.suffix == ".gml" else path.read_text(encoding="utf-8-sig", errors="ignore")
    for path in SOURCES
)
CHARS = {ord(char) for char in TEXT if ord(char) >= 32 and char not in "\r\n"}

for name in ("Galmuri11.ttf", "Galmuri11-Bold.ttf"):
    cmap = TTFont(ROOT / "datafiles" / name).getBestCmap()
    missing = sorted(CHARS - cmap.keys())
    print(f"{name}: {len(CHARS)} source characters checked; missing {len(missing)}")
    if missing:
        print("  " + " ".join(f"U+{code:04X}({chr(code)})" for code in missing))
        raise SystemExit(1)
