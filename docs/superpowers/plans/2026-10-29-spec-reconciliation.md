# 기획서·현행 코드 대조 및 잔여 작업 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 다섯 기획서의 미구현·불일치를 현재 사용자 결정과 대조하고, 실제로 필요한 기능을 구현한다.

**Architecture:** 2026-10-29 비교 페이지는 작업 목록으로 사용하되 최신 코드와 Google Docs 원문을 다시 확인한다. 제안이 현행 유지인 밸런스·복구·아이템 수치·그림자는 코드를 보존하고 기획서의 오래된 설명을 갱신한다. 선택 기능은 현재 플레이 경험에 이득이 명확한 경우에만 구현한다.

**Tech Stack:** GameMaker GML, PowerShell Runner capture, Python 정적 검사, Google Docs.

**Spec:** https://cushion-challenge-vs-2026-10-29-nv6c.pages.grok.bot/

## Global Constraints

- 경기 화면·조작·규칙 변경 전후 1280×720 게임 화면과 상호작용 영상을 `docs/devlog`에 기록한다.
- 기존 사용자 결정: 10만 점 차 복구 위험 샷, AI ±2000 접전 목표, 5쿠션 상한 해제는 유지한다.
- `제안`이 현행 유지인 항목은 게임 코드를 되돌리지 않는다.

## Review Focus

- 기획서가 오래되어 최신 코드에 이미 구현된 항목을 중복 구현하지 않는다.
- 대사 스킵이 오프닝 규칙·브레이크 배정 잠금을 건너뛰지 않는다.
- 대사 시간 변경이 AI 턴 시작을 막거나 대사를 잘라내지 않는다.
- 아이템 클릭이 큐 드래그로 이어지지 않는다.
- 폰트 한글 표시가 실제 Runner에서 누락되지 않는다.

## 작업

- [x] 수정 전 화면·영상 및 관련 규칙 상태 기록
- [x] 대사 스킵·짧은 반응 타이머 구현과 검증
- [x] 큐/상점 입력 간섭 및 한글 폰트 표시 확인; 실제 결함만 수정
- [x] 현행 유지 항목을 원 기획서에 명시해 오래된 구현 지시 교체
- [x] 빌드, 수정 후 같은 조건 촬영, 개발 일지와 독립 검토
