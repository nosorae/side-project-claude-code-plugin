# Side Project Claude Settings

사이드 프로젝트할 때 쓰는 내 Claude Code 세팅. 아이디어 검증부터 기획, 디자인, 개발, 배포까지 한 흐름으로.

직접 만든 기획→디자인→개발 파이프라인 플러그인에, 검증된 외부 플러그인 4개를 조합해서 씁니다.

---

## 전체 스택

```bash
# 1. 내 파이프라인 플러그인 (기획 → 디자인 → 개발 → 이슈)
/plugin marketplace add nosorae/side-project-claude-settings
claude plugin install side-project-claude-settings --scope project

# 2. 아이디어 검증 + 스타트업 방법론 (slavingia/skills — Gumroad 창업자)
#    validate-idea, mvp, pricing 등
/plugin marketplace add slavingia/skills
claude plugin install skills --scope project

# 3. PM / 고객 인터뷰 (phuryn/pm-skills — PM 전문)
#    product-discovery, customer-interview, prioritization 등
/plugin marketplace add phuryn/pm-skills
claude plugin install pm-skills --scope project

# 4. 개발 워크플로우 (superpowers — 15만 스타)
#    TDD, 서브에이전트 개발, 코드 리뷰, git worktree
/plugin install superpowers@claude-plugins-official

# 5. YC CEO 워크플로우 (garrytan/gstack — 7만 스타)
#    autoplan, checkpoint 패턴
/plugin marketplace add garrytan/gstack
claude plugin install gstack --scope project
```

---

## 왜 이 조합인가

| 단계 | 담당 플러그인 | 이유 |
|------|-------------|------|
| **아이디어 검증** | [slavingia/skills](https://github.com/slavingia/skills) (7.9K ★) | Gumroad 창업자의 Mom Test + Lean Canvas. 실전 경험 기반 |
| **고객 인터뷰** | [phuryn/pm-skills](https://github.com/phuryn/pm-skills) (10K ★) | PM 전문 100+ 스킬. 디스커버리부터 우선순위까지 |
| **기획 → 이슈** | **이 플러그인** | 3인 에이전트 토론 기획, 디자인 토큰 자동 생성, 로드맵, 이슈 자동 생성. 이건 직접 만듦 |
| **구현** | [superpowers](https://github.com/obra/superpowers) (152K ★) | TDD 강제, 서브에이전트 개발, 체계적 디버깅. 구현 품질 보장 |
| **워크플로우** | [garrytan/gstack](https://github.com/garrytan/gstack) (72K ★) | YC CEO의 autoplan/checkpoint. 대규모 작업 관리 |

---

## 이 플러그인의 흐름

### Step 1. 기획 — `/app-plan`

```
> 앱 기획해줘
```

3인 에이전트 토론(사용자/비즈니스/기술 관점) → 핵심 가치 → MVP 범위 → 유저 플로우 → PRD

**산출물:** `docs/ssot/prd/*-기획서.md` + `userflow.html` + `screen-map.html`

> 기획 전에 아이디어 검증이 필요하면 slavingia/skills의 `validate-idea`를 먼저 실행하세요.

### Step 2. 디자인 — `/design-system-to-figma` → `/prd-to-figma`

**디자인 시스템**: PRD 분석 → 디자인 토큰 생성 → 컴포넌트 HTML
**화면 디자인**: PRD 화면 정의 → 화면별 HTML (390x844)

**산출물:** `tokens.css`, `design-system.html`, `screen-*.html`

**강제:** frontend-design 스킬 미설치 시 자동 설치. 실패 시 중단.

### Step 3. 개발 계획 — `/dev-plan`

기술 아키텍처 → 디렉토리 구조 → 데이터 모델 → API 설계

**베스트 프랙티스 스킬 필수 설치** — 정적 목록이 아니라 실시간 검색으로 그 시점에 가장 좋은 스킬을 찾아 설치.

### Step 4. 배포 로드맵 — `/dev-roadmap`

M0~M3 마일스톤 → claude-task/human-task 분류

**작업 배치 순서 강제:**
1. 독립 claude-task (즉시 수행)
2. human-task (병렬)
3. 의존 claude-task (human-task 완료 후)

### Step 5. 이슈 생성 — `/create-issues`

로드맵 → GitHub Issues 자동 생성 (에픽 + 하위 작업, 라벨 자동)

### Step 6. 구현 + 코드 리뷰

구현은 superpowers가 담당 (TDD, 서브에이전트, git worktree).
커밋/PR 전에 `/code-review`로 프로젝트 규칙 + 스택 베스트 프랙티스 크로스체크.

---

## 전체 흐름

<img src="docs/diagrams/full-flow.png" alt="플러그인 설치부터 첫 배포까지" width="100%">

```
slavingia/skills          이 플러그인                      superpowers
─────────────    ──────────────────────────────    ─────────────────
validate-idea    /app-plan → PRD                   brainstorming
                    ↓                              writing-plans
                 /design-system-to-figma           executing-plans
                    ↓                              subagent-dev
                 /prd-to-figma                     code-review
                    ↓                              TDD
                 /dev-plan → 아키텍처               systematic-debugging
                    ↓
                 /dev-roadmap → 로드맵
                    ↓
                 /create-issues → GitHub
                    ↓
                 /code-review ←──────────────────→ 구현 (superpowers)
```

---

## 순서 강제 메커니즘

| 메커니즘 | 동작 |
|----------|------|
| **산출물 기반 전제조건** | 각 스킬이 선행 산출물 파일 존재 체크. 없으면 안내 + `--skip` 선택지 |
| **frontend-design 강제** | HTML 생성 스킬 3개가 실행 전 체크. 미설치 시 자동 설치, 실패 시 중단 |
| **베스트 프랙티스 스킬 실시간 검색** | dev-plan에서 기술 스택 결정 후 실시간 검색으로 설치. 스킵 불가 |
| **SSOT 변경 감지 hook** | docs/ssot/ 파일 변경 시 blueprint 업데이트 리마인드 |
| **작업 배치 순서** | 독립 claude-task → human-task → 의존 claude-task |
| **대화 기록 hook** | 모든 대화를 docs/sessions/에 자동 저장 |

---

## 이 플러그인의 스킬 목록

### 파이프라인

| 스킬 | 산출물 |
|------|--------|
| `/app-plan` | PRD + 유저플로우 HTML |
| `/design-system-to-figma` | `tokens.css` + `design-system.html` |
| `/prd-to-figma` | `screen-*.html` |
| `/dev-plan` | `dev-plan.md` + 아키텍처 HTML |
| `/dev-roadmap` | `deploy-roadmap.md` + 타임라인 HTML |
| `/create-issues` | GitHub Issues |
| `/code-review` | 프로젝트 규칙 + 스택 베스트 프랙티스 크로스체크 |

### 보조

| 스킬 | 설명 |
|------|------|
| `/product-blueprint` | SSOT 통합 마스터 HTML |
| `/handoff` | 세션 핸드오프 문서 생성 |
| `/resume` | 이전 세션 이어하기 |
| `/sync-roadmap` | 이슈 기반 로드맵 동기화 |
| `/sync` | Git pull + 충돌 해결 |
| `/clarify` | 모호한 요청 구체화 |

---

## 파이프라인 현황 조회

```
> 현황 보여줘

✅ 기획서 (docs/ssot/prd/2026-04-15-MyApp-기획서.md)
✅ 디자인 토큰 (docs/ssot/design/system/tokens.css)
⬜ 화면 디자인 — 다음: /prd-to-figma
⬜ 개발 계획
⬜ 배포 로드맵
⬜ GitHub Issues
```
