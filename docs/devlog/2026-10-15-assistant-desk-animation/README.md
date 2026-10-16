# 책상 뒤에서 모드를 설명하는 캐릭터 애니메이션

## 비포·애프터

- Before: 기존 `spr_assistant_dialogue`는 전신이 보이고 양팔을 조끼 앞에 움켜쥐고 있다. `before/standing_dialogue_sheet.png`와 `before/standing_dialogue_preview.mp4`는 기존 리소스를 재생해 만든 비교 자료다.
- After: `spr_assistant_desk_talk`는 책상 전경이 하반신을 가린다. 한쪽 팔은 책상에 놓고, 다른 팔로 모드를 설명하는 손동작을 한다. `after/assistant_desk_sheet.png`와 `after/assistant_desk_preview.mp4`에 결과를 기록했다.
- 이 영상은 스프라이트 프레임의 재생 미리보기이며, 실제 게임 화면을 녹화한 영상이 아니다. 메뉴 룸에는 아직 이 리소스를 배치하지 않았다.

## 프레임과 재생

`frames.json` 인덱스 순서: 대기 → 눈 깜박임 → 책상 위에서 말하기 → 손을 들어 설명 → 웃으며 설명 → 대기로 돌아오기. 원본 크기는 프레임당 512×512, 3열×2행이며 바깥 배경은 투명하다. GameMaker 리소스 시퀀스에 각 프레임의 재생 시간을 저장했다. 한 사이클은 약 1.95초다.

## 제작

내장 imagegen 도구에서 원본 캐릭터 이미지를 편집 대상으로, 사용자가 제공한 Coffee Talk 화면을 자세 참고 자료로 사용했다. 코트 제거, 캐릭터 정체성 유지, 책상 뒤 상반신 구도, 같은 팔로 이어지는 설명 동작과 투명 배경을 지시했다. `tools/package_assistant_desk_animation.py`가 생성 결과를 프레임별 PNG, 시트 PNG, GIF와 GameMaker 리소스로 정리한다.
