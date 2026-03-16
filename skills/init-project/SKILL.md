---
description: 새 사이드 프로젝트를 부트스트랩하는 스킬. 디렉토리 생성, git init, GitHub 레포 생성, 스킬/규칙 복사, 라벨 생성까지 한번에 수행
user_invocable: true
---

# Init Project (프로젝트 부트스트랩)

새 사이드 프로젝트를 시작할 때 필요한 모든 초기 설정을 한번에 수행하는 스킬입니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "새 프로젝트 시작", "프로젝트 초기화"
- "/init-project"
- "사이드 프로젝트 셋업해줘"

## 실행 단계

### Step 1: 프로젝트 정보 수집

**Actions:**

사용자에게 다음 정보를 물어본다:

1. **프로젝트 이름** (kebab-case, 예: `my-workout-app`)
2. **프로젝트 경로** (기본값: `~/side-project-{프로젝트이름}`)
3. **GitHub 레포 공개 여부** (`--public` 또는 `--private`, 기본값: `--private`)
4. **프로젝트 설명** (한 줄)

### Step 2: 디렉토리 및 Git 초기화

**Actions:**

```bash
# 디렉토리 생성 (또는 기존 디렉토리 확인)
mkdir -p {프로젝트경로}
cd {프로젝트경로}

# Git 초기화
git init

# GitHub 레포 생성
gh repo create {프로젝트이름} --{공개여부} --description "{설명}" --source=. --remote=origin
```

기존 디렉토리에 이미 git이 있으면 초기화를 건너뛴다.
기존 GitHub 레포가 있으면 생성을 건너뛴다.

### Step 3: 설정 템플릿 복사

**Actions:**

`side-project-claude-settings` 레포에서 필요한 파일을 복사한다:

```bash
# 소스 경로 (이 레포)
SOURCE=~/side-project-claude-settings

# 규칙 복사
mkdir -p {프로젝트경로}/.claude/rules
cp "$SOURCE/rules/"*.md {프로젝트경로}/.claude/rules/

# 스킬 복사 (init-project, sync 제외 — 템플릿 전용 스킬)
mkdir -p {프로젝트경로}/.claude/skills
for skill in app-plan design-system-to-figma prd-to-figma dev-plan dev-roadmap create-issues handoff; do
  cp -r "$SOURCE/skills/$skill" {프로젝트경로}/.claude/skills/
done

# hooks + settings 복사
mkdir -p {프로젝트경로}/hooks
cp "$SOURCE/hooks/"*.sh {프로젝트경로}/hooks/
chmod +x {프로젝트경로}/hooks/*.sh
cp "$SOURCE/.claude/settings.json" {프로젝트경로}/.claude/settings.json
```

> **참고**: 플랫폼별 전문 스킬(예: swift-concurrency, flutter-state, nextjs-patterns 등)은 `/dev-plan` 실행 시 tech stack 결정 후 자동으로 검색/설치됩니다. 이 단계에서는 범용 스킬만 복사합니다.

### Step 4: 프로젝트 구조 생성

**Actions:**

```bash
# 필수 디렉토리 생성
mkdir -p docs/ssot/prd
mkdir -p docs/ssot/design/system
mkdir -p docs/ssot/design/screens
mkdir -p docs/ssot/dev
mkdir -p docs/refs
mkdir -p docs/handoff
mkdir -p docs/lessons
mkdir -p docs/sessions

# .gitkeep 추가 (빈 디렉토리 유지)
touch docs/ssot/prd/.gitkeep
touch docs/ssot/design/system/.gitkeep
touch docs/ssot/design/screens/.gitkeep
touch docs/ssot/dev/.gitkeep
touch docs/refs/.gitkeep
touch docs/handoff/.gitkeep
touch docs/lessons/.gitkeep
touch docs/sessions/.gitkeep
```

### Step 5: GitHub 라벨 생성

**Actions:**

```bash
gh label create "epic" --description "에픽 이슈" --color "6f42c1" 2>/dev/null || true
gh label create "claude-task" --description "Claude Code가 독립 수행 가능한 작업" --color "0075ca" 2>/dev/null || true
gh label create "human-task" --description "사람이 직접 수행해야 하는 작업" --color "e4e669" 2>/dev/null || true
```

### Step 6: 초기 커밋

**Actions:**

```bash
git add -A
git commit -m "Init: 프로젝트 초기 설정

- 규칙 5개 + 스킬 7개 + hooks 복사
- docs/ 디렉토리 구조 생성 (ssot/prd, ssot/design, ssot/dev, refs, handoff, lessons, sessions)
- GitHub 라벨 생성 (epic, claude-task, human-task)"

git push -u origin main
```

### Step 7: 파이프라인 초기 이슈 생성

**Actions:**

프로젝트 파이프라인의 각 단계를 에픽 이슈로 미리 생성한다:

```bash
# 에픽 이슈 생성 (파이프라인 순서)
gh issue create --title "[Epic] 기획서(PRD) 작성" \
  --label "epic,claude-task" \
  --body "## 목표
/app-plan 스킬로 앱 기획서를 작성한다.

## 할일
- [ ] 아이디어 검증 (3인 에이전트 토론)
- [ ] 핵심 가치 정의
- [ ] MVP 범위 설정
- [ ] 유저 플로우 정의
- [ ] 기획서 저장 (docs/ssot/prd/YYYY-MM-DD-{앱이름}-기획서.md)

## 검증 방법
- [ ] docs/ssot/prd/ 에 기획서 파일 존재
- [ ] MVP 기능, 기술 스택, 유저 플로우가 포함됨"

gh issue create --title "[Epic] 디자인 시스템 생성" \
  --label "epic,claude-task" \
  --body "## 목표
/design-system-to-figma 스킬로 디자인 토큰과 시스템을 생성한다.

## 전제조건
- 기획서(PRD) 완료

## 할일
- [ ] 디자인 토큰 생성 (tokens.css)
- [ ] 디자인 시스템 HTML 생성
- [ ] Figma 내보내기

## 검증 방법
- [ ] docs/ssot/design/system/tokens.css 존재
- [ ] 디자인 시스템 HTML 렌더링 정상"

gh issue create --title "[Epic] 화면별 디자인 생성" \
  --label "epic,claude-task" \
  --body "## 목표
/prd-to-figma 스킬로 PRD 화면 정의를 HTML로 변환한다.

## 전제조건
- 기획서(PRD) 완료
- tokens.css 존재

## 할일
- [ ] 화면별 HTML 생성
- [ ] Figma 페이지 내보내기

## 검증 방법
- [ ] docs/ssot/design/screens/screen-*.html 파일 존재"

gh issue create --title "[Epic] 개발 계획서 작성" \
  --label "epic,claude-task" \
  --body "## 목표
/dev-plan 스킬로 기술 아키텍처와 개발 계획을 수립한다.

## 전제조건
- 기획서(PRD) 완료

## 할일
- [ ] 기술 아키텍처 설계
- [ ] 디렉토리 구조 정의
- [ ] 데이터 모델 설계
- [ ] API 설계
- [ ] 핵심 컴포넌트 정의

## 검증 방법
- [ ] docs/ssot/dev/dev-plan.md 존재"

gh issue create --title "[Epic] 배포 로드맵 작성" \
  --label "epic,claude-task" \
  --body "## 목표
/dev-roadmap 스킬로 마일스톤별 배포 로드맵을 생성한다.

## 전제조건
- docs/ssot/dev/dev-plan.md 완료

## 할일
- [ ] 마일스톤 분류 (M0~M3)
- [ ] 에픽/하위 작업 정의
- [ ] claude-task / human-task 분류
- [ ] 의존성 순서 정의

## 검증 방법
- [ ] docs/ssot/dev/deploy-roadmap.md 존재"

gh issue create --title "[Epic] 개발 이슈 생성" \
  --label "epic,claude-task" \
  --body "## 목표
/create-issues 스킬로 로드맵 기반 GitHub Issues를 생성한다.

## 전제조건
- docs/ssot/dev/deploy-roadmap.md 완료

## 할일
- [ ] 사용자와 이슈 범위 합의
- [ ] 에픽 이슈 생성
- [ ] 하위 작업 이슈 생성 (claude-task / human-task 라벨)
- [ ] 에픽 이슈에 하위 링크 업데이트

## 검증 방법
- [ ] 모든 로드맵 작업이 이슈로 생성됨"
```

### Step 8: 완료 안내

**Actions:**

사용자에게 결과를 안내한다:

```
프로젝트가 초기화되었습니다!

위치: {프로젝트경로}
GitHub: https://github.com/{사용자}/{프로젝트이름}

포함된 항목:
- 규칙 5개 (ssot, workflow, history, github-issues, meta)
- 스킬 7개 (app-plan, design-system-to-figma, prd-to-figma, dev-plan, dev-roadmap, create-issues, handoff)
- hooks (log-conversation: 대화 기록 자동 로깅)
- docs/ 디렉토리 구조 (ssot/prd, ssot/design, ssot/dev, refs/, handoff/, lessons/, sessions/)
- GitHub 라벨 (epic, claude-task, human-task)
- 파이프라인 초기 이슈 6개 (에픽)

다음 단계:
GitHub Issues 보드에서 첫 번째 이슈([Epic] 기획서 작성)부터 시작하세요.
```

---

## 모델 선택 가이드

- 전 과정: `sonnet` (CLI 명령 실행 + 파일 복사)

---

## 품질 체크리스트

- [ ] Git 레포가 정상 초기화되었는가?
- [ ] GitHub 레포가 생성/연결되었는가?
- [ ] 모든 규칙이 `.claude/rules/`에 복사되었는가?
- [ ] 모든 스킬이 `.claude/skills/`에 복사되었는가?
- [ ] `hooks/log-conversation.sh`가 복사되고 실행 권한이 있는가?
- [ ] `.claude/settings.json`에 UserPromptSubmit, PostToolUse hook이 설정되었는가?
- [ ] `docs/ssot/prd/`, `docs/ssot/design/system/`, `docs/ssot/design/screens/`, `docs/ssot/dev/`, `docs/refs/`, `docs/handoff/`, `docs/lessons/`, `docs/sessions/` 디렉토리가 존재하는가?
- [ ] GitHub 라벨 3개(epic, claude-task, human-task)가 생성되었는가?
- [ ] 초기 커밋이 push되었는가?

---

## 관련 스킬

- `app-plan` - 기획서 작성 (다음 단계)
