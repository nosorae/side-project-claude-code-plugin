---
description: 새 세션 시작 시 프로젝트 최신 상태를 파악하고 이어서 작업할 수 있게 하는 스킬. 핸드오프 문서, Git 히스토리, GitHub Issues, SSOT 문서를 종합 분석
---

# Resume (프로젝트 상태 파악 + 이어하기)

어떤 컴퓨터, 어떤 세션에서든 프로젝트의 최신 상태를 빠르게 파악하고 작업을 이어갈 수 있게 하는 스킬입니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "이어서 해줘", "현재 상태 파악해줘", "어디까지 했지?"
- "/resume"
- "프로젝트 상태", "컨텍스트 파악"

## 실행 단계

### Step 1: 최신 핸드오프 문서 확인 (가장 정확한 소스)

**Actions:**

`docs/handoff/` 에서 가장 최근 파일을 찾아 읽는다:

```bash
ls -t docs/handoff/*.md 2>/dev/null | head -1
```

- 핸드오프 문서가 있으면: **이 파일이 프로젝트 상태의 가장 정확한 스냅샷**이다
- 핸드오프 문서의 핵심 정보를 추출한다:
  - Goal (전체 목표)
  - Current Phase (현재 단계)
  - What Was Done (완료된 작업)
  - Remaining Plan (남은 계획)
  - Notes for Next Session (다음 세션 참고사항)

### Step 2: 핸드오프 이후 변경사항 확인

**Actions:**

핸드오프 문서 작성 이후 추가 변경이 있는지 확인한다:

```bash
# 핸드오프 파일의 커밋 해시
HANDOFF_COMMIT=$(git log -1 --format="%H" -- docs/handoff/ 2>/dev/null)

# 그 이후의 커밋들
git log --oneline ${HANDOFF_COMMIT}..HEAD 2>/dev/null
```

- 추가 커밋이 있으면: 핸드오프 이후 누군가(사람 또는 다른 세션)가 작업한 것
- 추가 커밋이 없으면: 핸드오프 문서가 최신 상태

### Step 3: GitHub Issues 상태 확인

**Actions:**

```bash
# 열린 이슈 목록
gh issue list --state open --limit 20

# 진행 중인 PR
gh pr list --state open
```

- 어떤 에픽이 열려있는지
- claude-task / human-task 분류 확인
- 가장 우선순위 높은 (번호가 낮은) 미완료 이슈 파악

### Step 4: SSOT 문서 존재 여부로 진행 단계 판단

**Actions:**

파이프라인의 각 단계별 산출물 존재 여부를 확인한다:

```bash
# 기획서 (PRD)
ls docs/ssot/*기획서*.md 2>/dev/null

# 디자인 토큰
ls docs/ssot/tokens.css 2>/dev/null

# 디자인 시스템
ls docs/ssot/design-system.html 2>/dev/null

# 화면별 디자인
ls docs/ssot/screen-*.html 2>/dev/null

# 개발 계획서
ls docs/ssot/dev-plan.md 2>/dev/null

# 배포 로드맵
ls docs/ssot/deploy-roadmap.md 2>/dev/null
```

파이프라인 진행도를 표로 정리:

```markdown
| 단계 | 산출물 | 상태 |
|------|--------|------|
| 기획서 (PRD) | docs/ssot/*기획서*.md | ✅/❌ |
| 디자인 토큰 | docs/ssot/tokens.css | ✅/❌ |
| 디자인 시스템 | docs/ssot/design-system.html | ✅/❌ |
| 화면별 디자인 | docs/ssot/screen-*.html | ✅/❌ |
| 개발 계획서 | docs/ssot/dev-plan.md | ✅/❌ |
| 배포 로드맵 | docs/ssot/deploy-roadmap.md | ✅/❌ |
```

### Step 5: Git 상태 확인

**Actions:**

```bash
# 현재 브랜치
git branch --show-current

# 미커밋 변경사항
git status --short

# 최근 커밋 5개
git log --oneline -5
```

### Step 6: 상태 요약 + 다음 액션 제안

**Actions:**

수집한 정보를 종합하여 사용자에게 보고한다:

```markdown
## 프로젝트 상태 요약

**프로젝트**: {프로젝트명}
**현재 단계**: {파이프라인에서의 위치}
**마지막 핸드오프**: {핸드오프 파일명} ({날짜})

### 파이프라인 진행도
{Step 4의 테이블}

### 미완료 이슈
{가장 우선순위 높은 이슈 3~5개}

### 다음 액션 제안
1. {가장 우선순위 높은 작업}
2. {그 다음 작업}

### 핸드오프에서 인계받은 참고사항
{핸드오프 문서의 Notes for Next Session}
```

사용자 확인: "이 상태에서 어떤 작업을 이어할까요?"

---

## 모델 선택 가이드

- 전 과정: `sonnet` (파일 읽기 + CLI 명령 + 종합 분석)

---

## 우선순위 판단 기준

상태 소스의 신뢰도 순서:

1. **핸드오프 문서** (`docs/handoff/`) — 가장 정확. 이전 세션이 직접 작성한 맥락
2. **GitHub Issues** — 작업 관리의 SSOT. 이슈 상태가 실제 진행도
3. **SSOT 문서 존재 여부** — 파이프라인 단계별 산출물로 객관적 판단
4. **Git log** — 시간순 변경 이력. 핸드오프 이후 변경 감지에 유용
5. **Git status** — 미커밋 작업 감지

핸드오프 문서가 없는 경우 2~5를 종합하여 상태를 추론한다.

---

## 품질 체크리스트

- [ ] 핸드오프 문서를 찾아 읽었는가?
- [ ] 핸드오프 이후 추가 변경사항을 확인했는가?
- [ ] GitHub Issues 상태를 확인했는가?
- [ ] SSOT 문서 존재 여부로 파이프라인 진행도를 파악했는가?
- [ ] 다음 액션을 구체적으로 제안했는가?

---

## 관련 스킬

- `create-issues` - 이슈 기반 작업 관리
