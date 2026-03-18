---
name: handoff
description: |
  세션 종료 시 핸드오프 문서를 생성하는 스킬. 현재 세션의 변경사항을 수집하고 다음 세션이 즉시 이어갈 수 있는 핸드오프 문서를 작성한다.
  이 스킬은 다음과 같은 요청에 반드시 사용한다: "핸드오프", "세션 정리", "작업 넘겨줘", "오늘 여기까지", "/handoff", "세션 종료".
  세션을 마무리하거나 작업을 다음 세션에 넘기는 맥락이면 이 스킬을 사용한다.
user_invocable: true
---

# Handoff (세션 핸드오프 문서 생성)

세션 종료 시 또는 유의미한 작업 완료 시, 다음 세션이 이 문서만 읽고 즉시 작업을 이어갈 수 있는 핸드오프 문서를 생성합니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "핸드오프", "핸드오프 문서 만들어줘"
- "/handoff"
- "세션 정리해줘", "인수인계 문서 작성"

## 실행 단계

### Step 1: 현재 세션 변경사항 수집

**Actions:**

```bash
# 최근 4시간 내 커밋 확인
git log --oneline --since="4 hours ago"

# 변경된 파일 목록
git diff --name-only HEAD~10..HEAD 2>/dev/null || git diff --name-only

# 현재 미커밋 변경사항
git status --short
```

- 커밋 히스토리와 diff에서 이번 세션의 작업 내용을 파악한다
- 사소한 수정(오타, 포맷팅 등)만 있으면 핸드오프가 불필요하다고 안내한다

### Step 2: 핸드오프 문서 작성

**Actions:**

아래 10개 필수 섹션을 포함하는 핸드오프 문서를 작성한다:

```markdown
# {프로젝트명} - {작업내용} Handoff

## Goal
전체 목표 (한 문장)

## Current Phase
현재 진행 단계와 파이프라인 내 위치

## What Was Done
- 이번 세션에서 완료한 것 (핵심 결정 포함)

## Key Decisions Made
- 내린 결정과 근거 (다음 세션이 같은 질문 반복 방지)

## What Worked
- 효과적이었던 접근법

## What Didn't Work / Caveats
- 주의할 점, 실패한 시도

## Key Files
- `path/to/file` - 설명

## Remaining Plan
1. 다음 세션이 실행할 구체적 단계

## Notes for Next Session
- 사용자 선호, 작업 규칙, 중요 맥락

## Quick Start Command
다음 세션 시작 시 아래 프롬프트를 사용:
```
{이어서 시작할 프롬프트}
```
```

### Step 3: 파일 저장

**Actions:**

```bash
# 파일 저장
# 파일명: docs/handoff/{프로젝트명}-{작업내용}-HANDOFF.md
# 같은 세션이름의 핸드오프가 있으면 덮어쓴다
```

- 세션 이름: `{프로젝트명}-{작업내용}` 형식 (예: `ai-judge-PRD작성-HANDOFF.md`)
- 저장 위치: `docs/handoff/`

### Step 4: 커밋 + 푸시

**Actions:**

```bash
git add docs/handoff/{파일명}
git commit -m "Handoff: {작업내용} 핸드오프 문서 작성"
git push
```

- 핸드오프 문서는 반드시 커밋+푸시하여 유실을 방지한다

---

## 모델 선택 가이드

- 전 과정: `sonnet` (git 명령 + 문서 작성)

---

## 품질 체크리스트

- [ ] 10개 필수 섹션이 모두 포함되었는가?
- [ ] Quick Start Command가 구체적인가? (다음 세션이 복사-붙여넣기로 바로 시작 가능)
- [ ] Key Files 경로가 정확한가?
- [ ] Remaining Plan이 실행 가능한 수준으로 구체적인가?
- [ ] 커밋+푸시가 완료되었는가?

---

## 관련 스킬

- `resume` - 핸드오프 문서를 읽고 작업을 이어가는 스킬
