---
name: init-project
description: |
  새 사이드 프로젝트를 부트스트랩하는 스킬. 플러그인이 자동 처리하지 않는 부분(rules 복사, docs 구조, GitHub 인프라, 라벨/마일스톤, 에픽 이슈 7개, branch protection)을 한번에 셋업한다.
  이 스킬은 다음과 같은 요청에 반드시 사용한다: "새 프로젝트 시작", "프로젝트 초기화", "사이드 프로젝트 셋업", "/init-project", "프로젝트 만들어줘", "레포 생성해줘", "init project".
  플러그인 설치 직후 새 프로젝트를 시작하거나 초기 환경을 세팅하는 맥락이면 이 스킬을 사용한다.
user_invocable: true
---

# Init Project (프로젝트 부트스트랩)

플러그인 설치 직후 한 번 실행해서, `/app-plan` 등 파이프라인 스킬이 정상 동작하는 데 필요한 모든 환경을 세팅합니다.

## 무엇을 하고, 무엇을 안 하나

**플러그인이 이미 처리한 것 (이 스킬은 건드리지 않음):**
- 스킬 등록 (`skills/`)
- hooks 등록 (`log-conversation`, `remind-blueprint-update`, `setup-companion-plugins`)
- 동반 플러그인 자동 설치 (superpowers, slavingia/skills, phuryn/pm-skills, garrytan/gstack)

**이 스킬이 추가로 처리하는 것:**
1. `gh` CLI + auth 확인
2. 프로젝트 정보 수집
3. Git/GitHub 레포 초기화 + `develop` 브랜치
4. **rules 복사** — 플러그인 시스템은 `rules/`를 사용자 프로젝트에 자동 배포할 수 없음 (path traversal 제약). init-project가 캐시에서 직접 복사한다
5. `docs/` 구조 + `product-blueprint.html` 스켈레톤
6. **GitHub 인프라 복사** — `.github/workflows/pr-check.yml`, `.github/ISSUE_TEMPLATE/`, `.git/hooks/pre-push`
7. 라벨 + `v0.1.0` 마일스톤 (SemVer: 첫 MVP)
8. Branch protection (무료 계정이면 스킵 + 안내)
9. 초기 커밋 + 에픽 이슈 7개

## 트리거 조건

- "새 프로젝트 시작", "프로젝트 초기화", "사이드 프로젝트 셋업해줘"
- `/init-project`

## 실행 단계

### Step 0: 사전 요구사항 확인

```bash
gh --version
```

- 미설치 + macOS → `brew install gh` 자동 시도
- 미설치 + 그 외 OS → 사용자에게 [공식 설치 가이드](https://cli.github.com/manual/installation) 안내 후 중단
- 설치 후: `gh auth status`
  - 미로그인 시 → 사용자에게 `gh auth login` 직접 실행을 안내 (대화형 명령)

### Step 1: 프로젝트 정보 수집

사용자에게 다음 4가지를 물어본다 (AskUserQuestion 활용 가능):

1. **프로젝트 이름** (kebab-case, 예: `my-workout-app`)
2. **프로젝트 경로** (기본값: `~/side-project-{프로젝트이름}`)
3. **GitHub 레포 공개 여부** (`--public` / `--private`, 기본값: `--private`)
4. **프로젝트 설명** (한 줄)

### Step 2: 디렉토리 + Git/GitHub 초기화

```bash
mkdir -p {프로젝트경로}
cd {프로젝트경로}

# 기존 git 있으면 init 스킵
[ ! -d .git ] && git init

# 기존 GitHub 레포 있으면 생성 스킵
gh repo view {프로젝트이름} >/dev/null 2>&1 || \
  gh repo create {프로젝트이름} --{공개여부} --description "{설명}" --source=. --remote=origin

# 초기 빈 커밋 (없으면 push가 거부됨)
[ -z "$(git log -1 2>/dev/null)" ] && \
  git commit --allow-empty -m "Init: 프로젝트 시작 (#0)" && \
  git branch -M main && \
  git push -u origin main

# develop 브랜치
git checkout -b develop 2>/dev/null || git checkout develop
git push -u origin develop
git checkout main
```

### Step 3: rules 복사

플러그인은 `rules/`를 사용자 프로젝트에 자동 배포할 수 없으므로 직접 복사한다.

```bash
# 플러그인 캐시 → 로컬 클론 → git clone 순으로 폴백
SOURCE=""
for candidate in \
  ~/.claude/plugins/cache/side-project-claude-code-plugin \
  ~/.claude/plugins/cache/nosorae/side-project-claude-code-plugin \
  ~/side-project-claude-code-plugin \
  ~/practice/side-project-claude-settings; do
  if [ -d "$candidate/rules" ]; then
    SOURCE="$candidate"
    break
  fi
done

if [ -z "$SOURCE" ]; then
  TMP=$(mktemp -d)
  git clone --depth 1 https://github.com/nosorae/side-project-claude-code-plugin.git "$TMP" || {
    echo "❌ rules 소스를 찾을 수 없습니다. 수동 클론 후 재시도하세요."
    exit 1
  }
  SOURCE="$TMP"
fi

mkdir -p {프로젝트경로}/.claude/rules
# 기존 .claude/rules 있으면 충돌 파일만 표시 후 사용자 확인
if compgen -G "{프로젝트경로}/.claude/rules/*.md" > /dev/null; then
  echo "⚠️  기존 .claude/rules/ 발견. 덮어쓸 파일:"
  diff -rq "$SOURCE/rules/" "{프로젝트경로}/.claude/rules/" 2>/dev/null | grep "differ\|Only in $SOURCE"
  # → 사용자에게 (a) 덮어쓰기 (b) 스킵 선택지 제공
fi
cp "$SOURCE/rules/"*.md {프로젝트경로}/.claude/rules/
```

> **왜 캐시에서 복사?** 공식 plugin spec은 path traversal을 금지해서 플러그인이 사용자 프로젝트에 임의 파일을 자동 배포할 수 없다. ([Plugins reference](https://code.claude.com/docs/en/plugins-reference.md))

### Step 4: docs 구조 + product-blueprint.html

```bash
cd {프로젝트경로}
mkdir -p docs/ssot/prd docs/ssot/design/system docs/ssot/design/screens \
         docs/ssot/dev docs/refs docs/handoff docs/lessons docs/sessions

for d in docs/ssot/prd docs/ssot/design/system docs/ssot/design/screens \
         docs/ssot/dev docs/refs docs/handoff docs/lessons docs/sessions; do
  touch "$d/.gitkeep"
done
```

**`docs/ssot/product-blueprint.html` 생성 조건:**
- `<title>`에 프로젝트 이름 포함
- 5개 탭: **기획** | **디자인 시스템** | **화면 디자인** | **개발 계획** | **로드맵**
- 각 탭에 placeholder 안내:
  - 기획: "아직 작성되지 않음 — `/app-plan` 실행 후 자동 업데이트됩니다"
  - 디자인 시스템: "`/design-system-to-figma` 실행 후 자동 업데이트됩니다"
  - 화면 디자인: "`/prd-to-figma` 실행 후 자동 업데이트됩니다"
  - 개발 계획: "`/dev-plan` 실행 후 자동 업데이트됩니다"
  - 로드맵: "`/dev-roadmap` 실행 후 자동 업데이트됩니다"
- standalone HTML (인라인 CSS만, 외부 의존성 X)
- 인라인 JavaScript로 탭 전환 + URL 해시 네비게이션 (`#기획`, `#디자인시스템`)

### Step 5: GitHub 인프라 복사

`templates/.github/`와 `templates/hooks/pre-push`를 사용자 프로젝트로 복사한다.

```bash
# Step 3에서 결정한 $SOURCE 재사용
mkdir -p {프로젝트경로}/.github/workflows {프로젝트경로}/.github/ISSUE_TEMPLATE
cp "$SOURCE/templates/.github/workflows/pr-check.yml" {프로젝트경로}/.github/workflows/
cp "$SOURCE/templates/.github/ISSUE_TEMPLATE/"*.md {프로젝트경로}/.github/ISSUE_TEMPLATE/

# pre-push hook은 .git/hooks/ 에 직접 복사 (core.hooksPath 변경 X — 다른 hook 충돌 방지)
HOOK_DEST={프로젝트경로}/.git/hooks/pre-push
if [ -f "$HOOK_DEST" ]; then
  echo "⚠️  기존 .git/hooks/pre-push 발견. 어떻게 처리할까요?"
  # (a) 백업 후 덮어쓰기 (HOOK_DEST → ${HOOK_DEST}.bak)
  # (b) 스킵 (사용자가 수동 병합)
  # → 사용자 응답 받아 처리
else
  cp "$SOURCE/templates/hooks/pre-push" "$HOOK_DEST"
fi
chmod +x "$HOOK_DEST"
```

> **왜 `core.hooksPath` 안 쓰나?** `core.hooksPath`는 모든 hook 경로를 강제 변경해서 commit-msg, pre-commit 등 다른 hook까지 영향. `.git/hooks/`에 직접 두면 git 기본 동작이라 충돌 0.

### Step 6: 라벨 + 마일스톤

```bash
gh label create "epic"        --description "에픽 이슈"                          --color "6f42c1" 2>/dev/null || true
gh label create "claude-task" --description "Claude Code가 독립 수행 가능한 작업" --color "0E8A16" 2>/dev/null || true
gh label create "human-task"  --description "사람이 직접 수행해야 하는 작업"       --color "e4e669" 2>/dev/null || true

# v0.1.0 마일스톤 (SemVer: 첫 MVP 출시 전 단계)
gh api repos/{owner}/{repo}/milestones -f title="v0.1.0" \
  -f description="첫 MVP 마일스톤" -f state="open" 2>/dev/null || true
```

### Step 7: Branch Protection (무료 계정이면 스킵 + 안내)

```bash
# private 레포 + free 플랜이면 스킵
IS_PRIVATE=$(gh api repos/{owner}/{repo} --jq .private)
USER_PLAN=$(gh api user --jq '.plan.name // "free"' 2>/dev/null)

if [ "$IS_PRIVATE" = "true" ] && [ "$USER_PLAN" = "free" ]; then
  echo "ℹ️  무료 GitHub 계정 + private 레포는 branch protection 사용 불가 (Pro 필요)"
  echo "   public 레포로 변경하거나 Pro 업그레이드 후 수동 설정하세요:"
  echo "   gh api -X PUT repos/{owner}/{repo}/branches/main/protection ..."
else
  gh api -X PUT repos/{owner}/{repo}/branches/main/protection \
    -f required_status_checks=null \
    -f enforce_admins=false \
    -f required_pull_request_reviews='{"required_approving_review_count":0}' \
    -f restrictions=null 2>/dev/null || \
    echo "⚠️  branch protection 설정 실패 (권한 부족 가능). 수동 설정 권장."
fi
```

### Step 8: 초기 커밋 + push

```bash
cd {프로젝트경로}
git add -A
git commit -m "Init: 프로젝트 부트스트랩 (#0)

- .claude/rules 복사
- docs/ 구조 (ssot, refs, handoff, lessons, sessions)
- product-blueprint.html 스켈레톤 (5탭)
- .github/ workflows + ISSUE_TEMPLATE
- pre-push hook"

git push origin main
```

### Step 9: 에픽 이슈 7개 생성

각 이슈는 **반드시 라벨(`epic` + `claude-task` 또는 `human-task`) + 마일스톤(`v0.1.0`)** 을 가진다 (github-enforcement 규칙 충족).

| # | 제목 | 라벨 | 다음 스킬 |
|---|------|------|-----------|
| 1 | [Epic] 기획서(PRD) 작성 | epic, claude-task | `/app-plan` |
| 2 | [Epic] 디자인 시스템 생성 | epic, claude-task | `/design-system-to-figma` |
| 3 | [Epic] 화면 디자인 생성 | epic, claude-task | `/prd-to-figma` |
| 4 | [Epic] 개발 계획서 작성 | epic, claude-task | `/dev-plan` |
| 5 | [Epic] 배포 로드맵 + 이슈 분해 | epic, claude-task | `/dev-roadmap` → `/create-issues` |
| 6 | [Epic] 외부 서비스 셋업 | epic, human-task | (수동) |
| 7 | [Epic] 첫 배포 (develop→main) | epic, human-task | (수동) |

```bash
# 예시 (1번)
gh issue create \
  --title "[Epic] 기획서(PRD) 작성" \
  --label "epic,claude-task" \
  --milestone "v0.1.0" \
  --body "## 목표
\`/app-plan\` 스킬로 앱 기획서를 작성한다.

## 할일
- [ ] 핵심 가치 정의 (3렌즈 토론)
- [ ] MVP 범위 설정
- [ ] 유저 플로우 정의
- [ ] 기획서 저장: docs/ssot/prd/YYYY-MM-DD-{앱이름}-기획서.md

## 검증
- [ ] docs/ssot/prd/ 에 기획서 파일 존재
- [ ] MVP 기능, 기술 스택, 유저 플로우 포함"
```

나머지 6개 이슈도 동일한 형식으로 생성한다 (제목/할일/검증만 변경).

## 완료 후 사용자에게 알릴 것

```
✅ 프로젝트 부트스트랩 완료

생성된 것:
- GitHub 레포: {url}
- 브랜치: main, develop
- .claude/rules/ ({N}개 규칙 파일)
- docs/ssot/, docs/refs/, docs/handoff/, ...
- product-blueprint.html (5탭 스켈레톤)
- .github/ (PR 체크 workflow + 이슈 템플릿)
- .git/hooks/pre-push (커밋 메시지 #N 강제)
- 라벨 3개 + 마일스톤 v0.1.0
- 에픽 이슈 7개

다음 단계:
  /app-plan    # 첫 에픽(#1) 시작
```

## 예외 상황

| 상황 | 대응 |
|------|------|
| 기존 디렉토리에 git 있음 | `git init` 스킵 |
| 기존 GitHub 레포 있음 | `gh repo create` 스킵 |
| 기존 `.claude/rules/` 있음 | 충돌 파일 표시 후 사용자 확인 |
| 기존 `.git/hooks/pre-push` 있음 | 백업/덮어쓰기/스킵 선택 |
| 무료 계정 + private | branch protection 스킵 + 안내 |
| `gh` 미설치 + 비-macOS | 공식 가이드 링크 안내 후 중단 |
| 모든 rules 소스 폴백 실패 | git clone fallback. 그래도 실패 시 사용자에게 수동 클론 안내 |
