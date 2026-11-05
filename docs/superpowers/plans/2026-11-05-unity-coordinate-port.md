# Unity GMS 좌표 이식 계획

> **For agentic workers:** Use superpowers:subagent-driven-development or superpowers:executing-plans; preserve the existing checkout and capture before changing gameplay.

**Goal:** GMS 룸 좌표를 물리에서 유지하면서 일반 스토리 공과 입력을 올바른 화면 좌표로 표시한다.

**Architecture:** `BilliardBallMotor`와 AI가 의존하는 transform 좌표는 GMS 좌표로 유지한다. 화면 표시의 변환은 별도의 공 렌더 경계에서 수행하고, 포인터는 역변환한다. GMS 원본 룸·공 그리기·입력을 기준으로 하고 부작용을 비교한다.

**Tech Stack:** Unity 6000.3.10f1, C#, GameMaker GML.

**Spec:** 사용자가 제공한 2026-11-05 Cushion Challenge 유니티 이식 계획 문서.

## Constraints and review focus

- 시작 전 실제 게임 촬영. 촬영 실패 시 원인을 기록한다.
- GMS 원본의 좌표 및 Sprite origin과 Unity import 상태를 직접 확인한다.
- 물리 transform, AI 입력 및 충돌·파울 복구 좌표의 의미를 보존한다.
- 정지 상태뿐 아니라 이동 중 표시 및 마우스 조준/배치 변환을 검증한다.
- 현재 스토리 배치와 원본 일반 모드의 차이는 구별한다. 물리 fixture를 덮어쓰지 않는다.

## 0단계

- [ ] 원본 GMS와 변경 전 Unity의 같은 모드·해상도 화면 및 동작을 촬영한다.
- [ ] 실제 코드 대조에 기반한 실패 테스트를 만들고 실행한다.
- [ ] 공 렌더 경계와 화면 입력의 좌표 변환을 구현한다. 필요한 Sprite 연결·설정을 원본과 대조한다.
- [ ] Unity 테스트, 기존 물리 추적 비교와 실제 동일 조건 캡처를 검증한다.
- [ ] 독립 검토와 개발 일지에 근거·한계를 남긴다.
