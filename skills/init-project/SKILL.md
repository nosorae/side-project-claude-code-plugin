---
name: init-project
description: |
  새 사이드 프로젝트를 부트스트랩하는 스킬. 플러그인 설치(스킬 16개 + hooks 2개) + 규칙 8개 복사, Git/GitHub 초기화, develop 브랜치 생성, 라벨 생성, product-blueprint 생성까지 한번에 수행한다.
  이 스킬은 다음과 같은 요청에 반드시 사용한다: "새 프로젝트 시작", "프로젝트 초기화", "사이드 프로젝트 셋업", "/init-project", "프로젝트 만들어줘", "레포 생성해줘".
  새 프로젝트를 시작하거나 초기 환경을 세팅하는 맥락이면 이 스킬을 사용한다.
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

### Step 0: 사전 요구사항 확인

**Actions:**

1. **GitHub CLI 확인**:
   ```bash
   gh --version
   ```
   - 설치되어 있으면 → Step 1로 진행
   - 미설치 시 → OS에 따라 자동 설치 시도:
     - macOS: `brew install gh` 실행
     - 그 외: 사용자에게 설치 안내 후 중단
   - 설치 완료 후 로그인 확인: `gh auth status`
     - 미로그인 시: 사용자에게 `gh auth login` 실행을 안내한다 (대화형 명령이므로 사용자가 직접 실행)

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

```bash
# develop 브랜치 생성
git checkout -b develop
git push -u origin develop
git checkout main
```

### Step 3: 플러그인 설치 + 프로젝트별 설정

**Actions:**

#### 3-1. 마켓플레이스 등록 + 플러그인 설치

```bash
cd {프로젝트경로}

# 마켓플레이스 등록 (최초 1회)
/plugin marketplace add nosorae/side-project-claude-settings

# 플러그인 설치 (프로젝트 스코프 — .claude/settings.json에 기록, Git 커밋 가능)
claude plugin install side-project-claude-settings@nosorae/side-project-claude-settings --scope project
```

> **플러그인이 제공하는 것**: 스킬 16개 + hooks 2개 (log-conversation, remind-blueprint-update)
> **플러그인이 제공하지 않는 것**: 규칙(rules) — 아래 3-2에서 별도 복사

> **왜 플러그인인가?** 기존 방식(파일 복사)은 원본이 업데이트되면 각 프로젝트에 수동 반영이 필요했다. 플러그인 방식은 원본 업데이트 시 모든 프로젝트에 자동 반영된다.

> **스킬 호출 방식**: 플러그인 스킬은 네임스페이스로 호출된다.
> 예: `/side-project-claude-settings:app-plan` 또는 자연어 트리거("앱 기획해줘")로도 자동 발동.

#### 3-2. 규칙 복사 (플러그인 미지원 — 필수)

플러그인은 규칙(rules)을 로드하지 않는다. 규칙은 프로젝트의 `.claude/rules/`에 직접 복사해야 한다:

```bash
SOURCE=~/.claude/plugins/cache/side-project-claude-settings
# 캐시 경로가 없으면 GitHub에서 직접
if [ ! -d "$SOURCE" ]; then
  SOURCE=~/side-project-claude-settings
fi

mkdir -p {프로젝트경로}/.claude/rules
cp "$SOURCE/rules/"*.md {프로젝트경로}/.claude/rules/
```

> **주의**: 기존 `.claude/rules/`가 있으면 사용자에게 덮어쓸지 확인. 충돌 파일만 표시한다.

#### 3-3. 예외 상황 처리

| 상황 | 대응 |
|------|------|
| 플러그인 이미 설치됨 | 건너뛴다 (`/plugin` → Installed 탭에서 확인) |
| 플러그인 설치 실패 (네트워크 오류) | 로컬 경로(`~/side-project-claude-settings`)에서 파일 직접 복사로 폴백 (아래 3-4 참조) |
| 로컬 레포도 없음 | `git clone https://github.com/nosorae/side-project-claude-settings.git ~/side-project-claude-settings` 후 폴백 절차 실행 |
| 프로젝트에 이미 `.claude/rules/` 존재 | 사용자에게 덮어쓸지 확인. 충돌 파일만 표시 |
| 프로젝트에 이미 `.claude/skills/` 존재 | 플러그인 스킬이 우선. 기존 커스텀 스킬은 유지 |

#### 3-4. 폴백 절차 (플러그인 설치 실패 시)

플러그인 설치가 실패하면 로컬 경로에서 규칙 + 스킬 + hooks + settings를 모두 직접 복사한다:

```bash
SOURCE=~/side-project-claude-settings

# 규칙 복사
mkdir -p {프로젝트경로}/.claude/rules
cp "$SOURCE/rules/"*.md {프로젝트경로}/.claude/rules/

# 스킬 복사 (init-project, skill-creator 제외 — 메타 레포 전용 스킬)
mkdir -p {프로젝트경로}/.claude/skills
for skill in app-plan market-research design-system-to-figma prd-to-figma dev-plan dev-roadmap create-issues handoff resume product-blueprint interview ideation sync-roadmap clarify sync; do
  cp -r "$SOURCE/skills/$skill" {프로젝트경로}/.claude/skills/
done

# hooks 복사 (플러그인이 없으면 직접 복사 필요)
mkdir -p {프로젝트경로}/hooks
cp "$SOURCE/hooks/"*.sh {프로젝트경로}/hooks/
chmod +x {프로젝트경로}/hooks/*.sh

# settings.json 복사 (hooks 설정 포함)
mkdir -p {프로젝트경로}/.claude
cp "$SOURCE/.claude/settings.json" {프로젝트경로}/.claude/settings.json
```

> **주의**: 폴백 복사 시에는 원본 업데이트가 자동 반영되지 않는다. 추후 네트워크가 복구되면 플러그인으로 전환을 권장한다.

> **참고**: 플랫폼별 전문 스킬(예: swift-concurrency, flutter-state, nextjs-patterns 등)은 `/dev-plan` 실행 시 tech stack 결정 후 자동으로 검색/설치됩니다.

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

3. **초기 product-blueprint.html 생성**

`docs/ssot/product-blueprint.html`을 아래 조건으로 생성한다:

- `<title>`에 프로젝트 이름을 포함한다
- 5개 탭 구조: **기획** | **디자인 시스템** | **화면 디자인** | **개발 계획** | **로드맵**
- 각 탭 내용에는 안내 문구를 표시한다:
  - 기획: "아직 작성되지 않음 — `/app-plan` 실행 후 자동 업데이트됩니다"
  - 디자인 시스템: "아직 작성되지 않음 — `/design-system-to-figma` 실행 후 자동 업데이트됩니다"
  - 화면 디자인: "아직 작성되지 않음 — `/prd-to-figma` 실행 후 자동 업데이트됩니다"
  - 개발 계획: "아직 작성되지 않음 — `/dev-plan` 실행 후 자동 업데이트됩니다"
  - 로드맵: "아직 작성되지 않음 — `/dev-roadmap` 실행 후 자동 업데이트됩니다"
- **standalone HTML**: 인라인 CSS만 사용, 외부 의존성 없음
- 탭 전환은 인라인 JavaScript로 구현
- URL 해시 기반 탭 네비게이션 지원 (`#기획`, `#디자인시스템` 등)

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

- hooks + settings.json 설정
- develop 브랜치 생성
- docs/ 디렉토리 구조 생성 (ssot/prd, ssot/design, ssot/dev, refs, handoff, lessons, sessions)
- 초기 product-blueprint.html 생성 (5개 탭 placeholder)
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
- [ ] 핵심 가치 정의 (3인 에이전트 토론)
- [ ] MVP 범위 설정
- [ ] 유저 플로우 정의
- [ ] 기획서 저장 (docs/ssot/prd/YYYY-MM-DD-{앱이름}-기획서.md)

> 시장 조사가 필요하면 /market-research를 먼저 실행하세요 (선택)

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
- 플러그인: side-project-claude-settings (스킬 16개 + hooks 2개 자동 적용)
- 규칙 8개 (.claude/rules/ 에 복사됨)
- Git Flow (main + develop 브랜치)
- docs/ 디렉토리 구조 (ssot/prd, ssot/design, ssot/dev, refs/, handoff/, lessons/, sessions/)
- 초기 product-blueprint.html (5개 탭 placeholder)
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
- [ ] 플러그인이 정상 설치되었는가? (또는 폴백으로 파일 복사 완료)
- [ ] `hooks/log-conversation.sh`가 복사되고 실행 권한이 있는가?
- [ ] `hooks/remind-blueprint-update.sh`가 복사되고 실행 권한이 있는가?
- [ ] `.claude/settings.json`에 UserPromptSubmit, PostToolUse hook이 설정되었는가 (log-conversation + remind-blueprint-update)?
- [ ] `docs/ssot/prd/`, `docs/ssot/design/system/`, `docs/ssot/design/screens/`, `docs/ssot/dev/`, `docs/refs/`, `docs/handoff/`, `docs/lessons/`, `docs/sessions/` 디렉토리가 존재하는가?
- [ ] `docs/ssot/product-blueprint.html`이 생성되었고, 5개 탭(기획/디자인 시스템/화면 디자인/개발 계획/로드맵)이 포함되어 있는가?
- [ ] `product-blueprint.html`이 standalone HTML(인라인 CSS, 외부 의존성 없음)인가?
- [ ] GitHub 라벨 3개(epic, claude-task, human-task)가 생성되었는가?
- [ ] 초기 커밋이 push되었는가?

---

## 관련 스킬

- `app-plan` - 기획서 작성 (다음 단계)
