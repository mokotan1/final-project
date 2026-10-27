# 갈무리11 UI 글꼴 적용 (2026-10-27)

## 변경

- 이미지 글리프 잘라 그리기 경로를 `Galmuri11.ttf`와 `Galmuri11-Bold.ttf`를 사용하는 공통 텍스트 렌더러로 교체했다. 일반 글자는 Regular, 강조 글자는 Bold를 사용한다.
- 화면마다 필요한 글자 크기로 TTF를 생성해 확대된 이미지 글꼴의 깨짐을 줄였다. 기존 그리기 함수 호출은 유지하고 실제 글자 폭을 사용하도록 바꿨다.
- 결과 화면은 패널 안에 제목·점수·버튼 문구가 들어가도록 8px 기준으로 조정했다. 스토리 HUD와 대사는 11px, 메인 메뉴 제목은 12px 기준으로 맞췄다.
- 기존 `spr_ui_glyph_atlas` 리소스는 과거 자료 확인을 위해 남아 있으나 새 텍스트 출력 경로에서는 사용하지 않는다. START 버튼 스타일, 물리, 점수, 스토리 50합 규칙은 변경하지 않았다.
- 폰트 출처: https://github.com/quiple/galmuri (SIL OFL 1.1). 라이선스 사본은 `datafiles/galmuri/LICENSE.txt`에 있다.

## 비포·애프터

- 메뉴: `before/startup/initial.png`, `before/startup/startup.mp4` ↔ `after/startup/initial.png`, `after/startup/startup.mp4`.
- 스토리 HUD와 대사: `before/story/story-final.png`, `before/story/story-flow.mp4` ↔ `after/story/story-final.png`, `after/story/story-flow.mp4`. 둘 다 `capture_story_flow.ps1`에서 같은 메뉴 입력으로 스토리에 진입했다.
- 영문 메뉴 추가 확인: `after/english-menu/initial.png`와 `startup.mp4`. 저장 언어를 건드리지 않는 테스트 빌드에서 영어를 강제했고, 촬영 뒤 임시 소스 변경을 되돌렸다.
- 결과: `before/result/initial.png`, `before/result/startup.mp4` ↔ `after/result/initial.png`, `after/result/startup.mp4`. 점수 1005370인 테스트 상태로 촬영했으며 저장 파일을 바꾸지 않았다.
- 비교용 수정 전 빌드는 전날 보관된 `Build/final_project.win` 및 결과 테스트 빌드다. 첫 시도는 제한된 셸에서 DLL 재배치 오류로 Runner가 시작되지 않았고, 데스크톱 권한 실행으로 위 자료를 실제 Runner에서 촬영했다.

## 검증

- GameMaker Igor VM 컴파일 통과. 실행 빌드: `output/final_project/final_project.win` (폰트 파일은 같은 출력 폴더에 포함).
- Runner에서 메뉴, 스토리 HUD·대사, 결과 화면을 촬영해 글자 영역과 줄 배치를 확인했다.
- `python tools/validate_project.py` 통과.
- `python tools/validate_galmuri_font.py`: UI GML 문자열과 스토리 JSON에서 사용된 514종 문자를 검사했고 Regular/Bold 모두 누락 0자.
- `.win`만 다른 폴더로 복사하면 글꼴이 빠진다. 배포할 때 `output/final_project/`의 TTF 두 파일을 `.win`과 함께 유지해야 한다.

## 남은 범위

- 한글/영문 전환 후 모든 대사 길이와 각 게임 상태별 동적 텍스트는 전체 플레이로 확인하지 않았다. 폰트 파일 자체는 한글 음절을 포함한다.
