# Before capture failure (this session)

`tools/capture_story_flow.ps1` was run twice against `Build/final_project.win` with `-DirectStory`, 1280×720 client capture.

Both runs failed at `PrintWindow failed` after the Runner started on the secondary monitor (1920,0). No `story-initial.png`, `story-final.png`, or `story-flow.mp4` were produced.

Pre-change behavior is described in `../2026-10-28-ai-gap-misplay/README.md` (schedule on 100k lead via AI item consideration, not player score loss).
