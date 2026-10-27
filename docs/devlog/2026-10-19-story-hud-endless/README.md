# 스토리 HUD를 엔드리스 화면 형식에 맞추기

## 작업 전

- `before/user-story-before.png`: 사용자가 제공한 스토리 모드 실제 화면. 이번 작업에서 직접 촬영한 자료는 아니다.
- `before/user-endless-reference.png`: 사용자가 제공한 엔드리스 모드 화면. 목표 UI 참고 자료다.
- 코드 변경 전 `tools/capture_startup.ps1`로 기존 `Build/final_project.win` 실행을 시도했으나 Windows `{잘못된 DLL 재할당}` 오류로 Runner 창이 열리지 않았다. 따라서 이번 작업에서 직접 촬영한 스크린샷이나 영상은 없다.

## 작업 후

- 엔드리스 모드와 같은 상단 POWER 게이지·어두운 2행 패널을 스토리 HUD에 적용했다. 스토리 규칙에 맞춰 손님과 바텐더의 점수·기회·스테이지 목표 진행, 현재 차례, 최소 쿠션 수와 파울 감점·위험 샷 전용·기회 회복 제한을 표시한다.
- 하단 상점 슬롯은 상대 차례에도 남아 있으며 구매할 수 없는 동안 어둡게 표시한다. 기존 구매 입력, 결과 화면, 대화창을 유지했다.
- `tools/test_story_versus.py`, `tools/validate_project.py`와 GameMaker Igor VM 컴파일을 통과했다. `tools/validate_korean_font.py`는 프로젝트의 기존 GML 대사들에서 스프라이트 폰트에 없는 한글 음절을 감지해 실패했다. 이번 HUD의 새 표시 문구는 현재 폰트 글리프만 사용하도록 확인했다.
- 새 빌드에서 `tools/capture_startup.ps1`로 촬영을 재시도했지만 같은 Windows `{잘못된 DLL 재할당}` 오류로 Runner 창이 열리지 않았다. `after/`에 실제 게임 화면·영상은 없으며, 화면 배치는 런타임에서 확인되지 않았다.
