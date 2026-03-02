---
description: 새 사이드 프로젝트를 부트스트랩하는 스킬. 디렉토리 생성, git init, GitHub 레포 생성, 스킬/규칙 복사, 라벨 생성까지 한번에 수행
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
for skill in app-plan figma-design-system prd-to-figma dev-plan dev-roadmap create-issues; do
  cp -r "$SOURCE/skills/$skill" {프로젝트경로}/.claude/skills/
done

# hooks + settings 복사
mkdir -p {프로젝트경로}/hooks
cp "$SOURCE/hooks/"*.sh {프로젝트경로}/hooks/
chmod +x {프로젝트경로}/hooks/*.sh
cp "$SOURCE/.claude/settings.json" {프로젝트경로}/.claude/settings.json
```

### Step 4: 프로젝트 구조 생성

**Actions:**

```bash
# 필수 디렉토리 생성
mkdir -p docs/dialogs
mkdir -p docs/lessons

# .gitkeep 추가 (빈 디렉토리 유지)
touch docs/dialogs/.gitkeep
touch docs/lessons/.gitkeep
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

- 규칙 5개 + 스킬 6개 + hooks 복사
- docs/ 디렉토리 구조 생성
- GitHub 라벨 생성 (epic, claude-task, human-task)"

git push -u origin main
```

### Step 7: 완료 안내

**Actions:**

사용자에게 결과를 안내한다:

```
프로젝트가 초기화되었습니다!

위치: {프로젝트경로}
GitHub: https://github.com/{사용자}/{프로젝트이름}

포함된 항목:
- 규칙 5개 (ssot, workflow, history, github-issues, meta)
- 스킬 6개 (app-plan, figma-design-system, prd-to-figma, dev-plan, dev-roadmap, create-issues)
- hooks (enforce-dialog: 대화 기록 강제)
- docs/ 디렉토리 구조 (dialogs/, lessons/)
- GitHub 라벨 (epic, claude-task, human-task)

다음 단계:
1. /app-plan → 기획서 작성
2. 기술 스택에 맞는 프레임워크 셋업
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
- [ ] `hooks/enforce-dialog.sh`가 복사되고 실행 권한이 있는가?
- [ ] `.claude/settings.json`에 Stop hook이 설정되었는가?
- [ ] `docs/`, `docs/dialogs/`, `docs/lessons/` 디렉토리가 존재하는가?
- [ ] GitHub 라벨 3개(epic, claude-task, human-task)가 생성되었는가?
- [ ] 초기 커밋이 push되었는가?

---

## 관련 스킬

- `app-plan` - 기획서 작성 (다음 단계)
