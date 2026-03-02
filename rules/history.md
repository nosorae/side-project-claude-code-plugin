# 세션 핸드오프

유의미한 작업 완료 시 또는 세션 종료 시 핸드오프 문서를 작성한다. 다음 세션이 이 파일만 읽고 즉시 작업을 이어갈 수 있는 수준으로 작성해야 한다.

## 기록 규칙

- 기록 위치: `docs/handoff/{세션이름}-HANDOFF.md`
- 세션 이름: `{프로젝트명}-{작업내용}` 형식 (예: `ai-judge-PRD작성-HANDOFF.md`)
- 기록 시점: 기능 구현, 아키텍처 결정, 중요한 버그 수정 등 유의미한 작업 완료 시 또는 세션 종료 시
- 기록 후 즉시 커밋+푸시하여 유실 방지
- 사소한 수정(오타, 포맷팅 등)은 기록하지 않는다
- 같은 세션이름의 핸드오프가 있으면 덮어쓴다

## 필수 섹션

| 섹션 | 설명 |
|------|------|
| **Goal** | 전체 목표 (한 문장) |
| **Current Phase** | 현재 진행 단계와 파이프라인 내 위치 |
| **What Was Done** | 이번 세션에서 완료한 것 (핵심 결정 포함) |
| **Key Decisions Made** | 내린 결정과 근거 (다음 세션이 같은 질문 반복 방지) |
| **What Worked** | 효과적이었던 접근법 |
| **What Didn't Work / Caveats** | 주의할 점, 실패한 시도 |
| **Key Files** | 관련 파일 경로 목록 |
| **Remaining Plan** | 다음 세션이 실행할 구체적 단계 |
| **Notes for Next Session** | 사용자 선호, 작업 규칙, 중요 맥락 |
| **Quick Start Command** | 다음 세션 시작 시 사용할 프롬프트 |

## 템플릿

```markdown
# {프로젝트명} - {작업} Handoff

## Goal
...

## Current Phase
...

## What Was Done
- ...

## Key Decisions Made
- ...

## What Worked
- ...

## What Didn't Work / Caveats
- ...

## Key Files
- `path/to/file` - 설명
- ...

## Remaining Plan
1. ...
2. ...

## Notes for Next Session
- ...

## Quick Start Command
다음 세션 시작 시 아래 프롬프트를 사용:
```
{이어서 시작할 프롬프트}
```
```

## 강제 메커니즘

`Stop` hook(`hooks/enforce-dialog.sh`)이 세션 종료 시 자동 검사한다:
- 최근 4시간 내 작업 커밋이 있는데 `docs/handoff/` 커밋이 없으면 종료를 차단한다
- 핸드오프 문서를 작성하고 커밋+푸시해야 세션 종료가 가능하다
