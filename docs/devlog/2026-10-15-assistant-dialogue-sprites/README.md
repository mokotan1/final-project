# 코트 없는 안내 캐릭터 대화 스프라이트

- Before: 기존 `spr_assistant_pixel` 원본. 갈색 코트를 입고 한 가지 표정만 있다.
- After: 코트를 벗기고 노란 조끼, 흰 반소매 셔츠, 남색 넥타이와 치마를 유지한 6프레임 시트. 표정과 입 모양은 `sprites/spr_assistant_dialogue/frames.json`의 인덱스 순서다.
- 각 프레임 342×768, 3열×2행, 투명 PNG. GameMaker 리소스 `spr_assistant_dialogue`로 등록했다. 프레임 0~5는 지정해서 사용하며 자동 재생은 0 FPS다.
- 메뉴 룸에는 아직 배치하지 않았으므로 게임 화면의 실행 전후 촬영은 해당하지 않는다. 이 폴더의 before/after는 리소스 비교용이다.
- 생성: 내장 imagegen 도구로 원본 캐릭터를 참조해 코트를 제거하고 표정을 만들었다. `tools/package_assistant_dialogue.py`로 투명도와 프레임 정렬을 정리했다.
