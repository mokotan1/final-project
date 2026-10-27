# 메인 메뉴 픽셀 밀도와 물가 경계

## 변경
- 사용자 제공 모드 선택 화면의 또렷한 픽셀 크기를 참고해 1280×720 메인 메뉴 야경 배경을 교체했다.
- 가게 문 앞에 돌바닥과 높이가 드러나는 둑 턱을 만들고, 턱 왼편의 짙은 강물 및 수평 반사와 구분했다.
- 새 배경의 위치에 맞춰 별·빌딩 창문·OPEN 네온 점멸 레이어를 다시 만들었다. 켜진 불빛을 기본 배경에서 분리해 점멸 때 실제 밝기 차이가 나도록 했다.

## 비교 자료
- `before/menu_background_before.png`: 변경 직전 게임 스프라이트 사본.
- `after/menu_background_after_resource.png`: 변경 후 게임 스프라이트 사본.
- `before/previous_flicker_preview.mp4`: 이전 리소스의 점멸 미리보기 영상.
- `after/menu_flicker_after_resource.mp4`: 새 배경과 별·창문·OPEN 간판 레이어를 실제 메뉴 Draw 이벤트의 시간식대로 합성한 6초 미리보기 영상.
- `after/menu_flicker_frame_resource.png`: 새 점멸 영상의 한 프레임.
- 이미지와 영상은 리소스 비교 자료이며 실제 게임 화면 촬영은 아니다. 이번 작업 중 GameMaker Runner를 실행해 촬영하지 못해 게임 실행 화면과 영상은 없다.

## 확인
- 전후 리소스가 모두 1280×720이며 수정된 배경에서 돌바닥·둑 턱·강물이 따로 읽히는지 육안으로 확인했다.
- `python tools/validate_presentation_resources.py` 통과.
- 새 점멸 영상은 1280×720, 6초이며, 별·창문·네온 레이어에 불투명 픽셀이 존재하는 것을 확인했다. 영상 프레임 해시가 시간에 따라 변하는 것도 확인했다.
- 원본 배경은 내장 image_gen 편집 도구로 만들었고, 결과를 1280×720으로 최근접 축소했다. 최종 리소스는 `datafiles/opening_night_city/opening_city_pixel_quay_1280.png` 및 대응하는 `spr_menu_*` 스프라이트에 저장했다.
