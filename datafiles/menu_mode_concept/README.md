# 모드 선택 룸 시안과 에셋

- `mode_selection_draft_v4_story_modes.png`: 승인한 1280×720 구성 시안. STORY·ENDLESS·CLASSIC 및 START·BACK이 보인다.
- `mode_selection_background_only.png`: 버튼과 텍스트를 제거한 1280×720 배경.
- `mode_selection_assets_preview.png`: 등록한 배경과 버튼 스프라이트를 분리된 PNG에서 다시 합성한 검토용 이미지. 실제 게임 캡처가 아니다.
- `assets_manifest.json`: 각 버튼의 GameMaker 스프라이트 이름, 시안 기준 좌표, 크기.

GameMaker 프로젝트에 `spr_mode_select_bg`, `spr_mode_select_story`, `spr_mode_select_endless`, `spr_mode_select_classic`, `spr_mode_select_start`, `spr_mode_select_back`을 각각 등록했다. 버튼 PNG는 투명 배경이며, 배경과 별개로 배치할 수 있다. 이번 작업은 리소스 등록만 포함하고 룸·오브젝트 파일은 수정하지 않았다.

배경 빈 버전은 내장 imagegen으로 시안에서 버튼을 지워 만들었다. 버튼은 승인 시안의 해당 영역을 프레임 그대로 분리했다. 모두 실제 화면 크기에 맞춘 픽셀 리소스다.
