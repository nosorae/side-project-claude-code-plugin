# Side Project Claude Settings

사이드 프로젝트에서 재사용하는 Claude Code 규칙 + 스킬 모음.

## 전체 파이프라인

```
app-plan → figma-design-system → prd-to-figma → dev-plan → dev-roadmap → create-issues
(기획서)    (토큰+디자인시스템)    (화면별 디자인) (개발 계획)  (배포 로드맵)  (이슈 생성)
```

## 구조

```
side-project-claude-settings/
├── .claude-plugin/
│   └── plugin.json           # 플러그인 매니페스트
├── rules/                    # 규칙 (→ .claude/rules/ 에 복사)
│   ├── ssot.md               # SSOT 문서 구조 + 파이프라인
│   ├── workflow.md            # 워크플로우 원칙 (0~8)
│   ├── history.md             # 히스토리 기록
│   ├── github-issues.md       # GitHub Issues 작업 관리
│   └── meta.md                # 메타 규칙 (규칙 파일 통제)
├── skills/                    # 스킬 (→ .claude/skills/ 에 복사)
│   ├── app-plan/              # 앱 기획
│   ├── figma-design-system/   # 디자인 시스템
│   ├── prd-to-figma/          # 화면별 디자인
│   ├── dev-plan/              # 개발 계획서
│   ├── dev-roadmap/           # 배포 로드맵
│   ├── create-issues/         # GitHub Issues 생성
│   ├── init-project/          # 프로젝트 부트스트랩
│   └── sync/                  # Git 동기화
└── README.md
```

## 포함된 규칙

| 규칙 | 설명 |
|------|------|
| `ssot` | SSOT 문서 구조, 스킬 파이프라인, 경계 규칙 |
| `workflow` | 요구사항 구체화, 계획 우선, 단순함, 정밀 변경 등 9개 원칙 |
| `history` | 세션 종료 시 `docs/handoff/`에 핸드오프 문서 작성 (Stop hook 강제) |
| `github-issues` | GitHub Issues 기반 작업 관리 (에픽/하위, 라벨, 템플릿) |
| `meta` | 규칙 파일 변경 시 사용자 확인 필수 |

## 포함된 스킬

| 스킬 | 설명 |
|------|------|
| `app-plan` | 4단계 앱 기획 (아이디어 검증 → 가치 정의 → MVP → 유저 플로우) |
| `figma-design-system` | PRD → 디자인 시스템 HTML → Figma 내보내기 |
| `prd-to-figma` | PRD 화면 정의 → 화면별 HTML → Figma 페이지 |
| `dev-plan` | PRD + 디자인 → 기술 아키텍처, 데이터 모델, API 설계 |
| `dev-roadmap` | 개발 계획서 → 마일스톤/에픽 분류, claude-task/human-task 구분 |
| `create-issues` | 로드맵 → GitHub Issues 자동 생성 (에픽 + 하위 작업) |
| `resume` | 새 세션에서 프로젝트 상태 파악 + 이어하기 (핸드오프/이슈/SSOT 종합) |
| `init-project` | 새 프로젝트 부트스트랩 (git, GitHub, 규칙/스킬 복사, 라벨) |
| `sync` | Git pull + 충돌 해결 + 변경 내역 표시 |

## 설치

### 방법 1: `/init-project` 스킬 (추천)

새 프로젝트에서 `/init-project`를 실행하면 자동으로:
1. 디렉토리 생성 + `git init` + GitHub 레포 생성
2. 규칙 5개를 `.claude/rules/`에 복사
3. 스킬 6개를 `.claude/skills/`에 복사
4. `docs/` 디렉토리 구조 생성 (`handoff/`, `lessons/`)
5. GitHub 라벨 생성 (`epic`, `claude-task`, `human-task`)

### 방법 2: 수동 복사

```bash
SOURCE=~/side-project-claude-settings
TARGET=<프로젝트경로>

# 규칙 복사
mkdir -p "$TARGET/.claude/rules"
cp "$SOURCE/rules/"*.md "$TARGET/.claude/rules/"

# 스킬 복사
mkdir -p "$TARGET/.claude/skills"
cp -r "$SOURCE/skills/app-plan" "$TARGET/.claude/skills/"
cp -r "$SOURCE/skills/dev-plan" "$TARGET/.claude/skills/"
# ... 필요한 스킬만 선택 복사
```

### 방법 3: 심링크 (규칙 공유)

여러 프로젝트에서 동일한 규칙을 공유하려면:

```bash
# 규칙 디렉토리 심링크
ln -s ~/side-project-claude-settings/rules <프로젝트>/.claude/rules

# 또는 개별 규칙만
ln -s ~/side-project-claude-settings/rules/workflow.md <프로젝트>/.claude/rules/workflow.md
```

### 방법 4: 플러그인 설치 (스킬만)

`.claude-plugin/plugin.json`이 포함되어 있어 플러그인으로 설치 가능:

```bash
claude plugin install --plugin-dir ~/side-project-claude-settings
```

> **참고**: 플러그인으로는 스킬만 설치됩니다. 규칙은 별도로 복사하거나 심링크해야 합니다.

## 스킬 의존성

```
app-plan → figma-design-system → prd-to-figma (tokens.css 선행 필요)
dev-plan → dev-roadmap → create-issues (순차 실행)
```

- `figma-design-system`과 `prd-to-figma`는 `frontend-design:frontend-design` 스킬이 있으면 디자인 품질이 향상됩니다.
- `dev-plan`은 기획서(PRD)가 필요합니다.
- `create-issues`는 GitHub 레포 연결이 필요합니다.
