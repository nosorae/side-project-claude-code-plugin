# Side Project Claude Settings

사이드 프로젝트를 혼자서 처음부터 끝까지 만들어보려고 하면, 생각보다 막막한 부분이 많습니다.

"아이디어는 있는데 어디서부터 시작하지?" "기획서는 어떻게 써야 하지?" "디자인은?" "개발은 어떤 순서로?"

이 레포는 그런 문제를 해결하기 위해 만든 **내 개인 Claude Code 세팅**입니다. 아이디어 검증부터 기획, 디자인, 개발 계획, 이슈 관리, 구현까지 — 순서대로 따라가기만 하면 되도록 설계했습니다.

모든 걸 직접 만든 건 아닙니다. 잘 만들어진 외부 플러그인이 있으면 그걸 쓰고, 없는 부분만 직접 만들었습니다.

---

## 이 세팅이 뭘 해주는지

한마디로 요약하면: **"다음에 뭐 해야 하지?"를 없애줍니다.**

1. 아이디어가 있으면 → 검증부터 시켜줍니다
2. 검증이 끝나면 → 기획서(PRD)를 자동으로 작성합니다
3. 기획서가 있으면 → 디자인 토큰과 화면을 만들어줍니다
4. 디자인이 끝나면 → 개발 계획서를 잡아줍니다
5. 계획이 있으면 → 마일스톤별 로드맵을 짜줍니다
6. 로드맵이 있으면 → GitHub 이슈를 자동으로 생성합니다
7. 이슈가 있으면 → 하나씩 구현합니다

각 단계는 이전 단계의 결과물이 있어야만 진행됩니다. 순서를 건너뛰려고 하면 "먼저 이걸 해야 합니다"라고 안내해주고, 정말 건너뛰고 싶으면 `--skip` 옵션도 있습니다.

---

## 설치

플러그인 5개를 설치합니다. 하나는 직접 만든 것이고, 나머지 4개는 각 분야에서 가장 잘 만들어진 외부 플러그인입니다.

```bash
# 이 플러그인 — 기획 → 디자인 → 개발 → 이슈 파이프라인
/plugin marketplace add nosorae/side-project-claude-settings
claude plugin install side-project-claude-settings --scope project

# 아이디어 검증 — Gumroad 창업자가 만든 스타트업 방법론
/plugin marketplace add slavingia/skills
claude plugin install skills --scope project

# PM 스킬 — 고객 인터뷰, 제품 디스커버리
/plugin marketplace add phuryn/pm-skills
claude plugin install pm-skills --scope project

# 개발 워크플로우 — TDD, 서브에이전트 개발, 코드 리뷰
/plugin install superpowers@claude-plugins-official

# YC CEO 워크플로우 — 자동 계획, 체크포인트
/plugin marketplace add garrytan/gstack
claude plugin install gstack --scope project
```

설치가 끝나면 바로 `"앱 기획해줘"` 또는 `/app-plan`으로 시작할 수 있습니다.

---

## 왜 이 조합인가

전부 직접 만들 수도 있었지만, 잘 만들어진 게 이미 있으면 그걸 쓰는 게 맞다고 생각했습니다.

| 영역 | 플러그인 | 왜 이걸 고른 건지 |
|------|---------|----------------|
| 아이디어 검증 | [slavingia/skills](https://github.com/slavingia/skills) | Gumroad 창업자 Sahil Lavingia가 직접 만듦. Mom Test, Lean Canvas 같은 검증 방법론이 스킬로 들어있음 |
| 고객 인터뷰 | [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | PM 전문 스킬 100개 이상. 인터뷰나 디스커버리를 직접 만드는 것보다 이게 훨씬 체계적 |
| 기획~이슈 | **이 플러그인** | 기획서 작성, 디자인 토큰 생성, 화면 HTML, 개발 계획, 로드맵, 이슈 자동 생성. 이 흐름은 기존에 없어서 직접 만듦 |
| 구현 | [superpowers](https://github.com/obra/superpowers) | 15만 스타. TDD 강제, 서브에이전트 기반 개발, 체계적 디버깅. 구현 품질을 이것에 맡김 |
| 워크플로우 | [garrytan/gstack](https://github.com/garrytan/gstack) | YC CEO Garry Tan의 세팅. 7만 스타. 큰 작업을 자동으로 쪼개고 체크포인트를 잡아줌 |

---

## 실제 사용 흐름

### 0. 아이디어가 있을 때 — 먼저 검증

아이디어가 괜찮은지 확인하고 싶으면 slavingia/skills의 `validate-idea`를 씁니다. Mom Test 방식으로 아이디어를 검증해주고, Lean Canvas도 만들어줍니다.

고객 인터뷰가 필요하면 phuryn/pm-skills의 PM 디스커버리 스킬을 씁니다.

이 단계는 선택입니다. 이미 검증된 아이디어가 있으면 바로 기획으로 넘어가면 됩니다.

### 1. 기획 — `/app-plan`

```
> 앱 기획해줘
```

세 명의 에이전트가 각각 다른 관점에서 토론합니다:
- **사용자 옹호자**: 사용자가 진짜 원하는 게 뭔지
- **비즈니스 전략가**: 어떻게 돈을 벌 건지
- **기술 현실주의자**: AI 코딩으로 실현 가능한지

토론 결과를 바탕으로 핵심 가치, MVP 범위, 유저 플로우를 정하고, 기획서(PRD)를 작성합니다.

**만들어지는 것:**
- `docs/ssot/prd/` 아래에 기획서 마크다운
- `userflow.html` — 유저 플로우 다이어그램
- `screen-map.html` — 화면 전환 흐름도

### 2. 디자인 — `/design-system-to-figma` → `/prd-to-figma`

기획서가 있어야 실행됩니다. 없으면 "먼저 `/app-plan`을 실행하세요"라고 안내합니다.

**디자인 시스템 생성:**
앱 성격에 맞는 디자인 토큰(색상, 타이포, 간격)을 만들고, 컴포넌트 시스템을 HTML로 생성합니다.

**화면별 디자인:**
기획서의 화면 정의를 읽고, 각 화면을 390x844 모바일 HTML로 만들어줍니다. 브라우저에서 바로 확인할 수 있습니다.

HTML을 만들기 전에 `frontend-design` 스킬이 설치되어 있는지 확인합니다. 없으면 자동으로 설치하고, 그마저 실패하면 멈춥니다. 디자인 품질을 위해 이 부분은 양보하지 않습니다.

### 3. 개발 계획 — `/dev-plan`

기술 아키텍처, 디렉토리 구조, 데이터 모델, API를 설계합니다.

여기서 중요한 건 **베스트 프랙티스 스킬 설치**입니다. 기술 스택이 정해지면, 그 스택에 맞는 베스트 프랙티스 스킬을 실시간으로 검색해서 설치합니다. 어떤 스킬이 좋은지는 시점마다 다르기 때문에, 정적인 추천 목록을 두지 않고 매번 최신 검색을 합니다. 이 단계는 건너뛸 수 없습니다.

### 4. 배포 로드맵 — `/dev-roadmap`

개발 계획을 마일스톤(M0~M3)으로 나누고, 각 작업을 분류합니다:
- **claude-task**: Claude Code가 혼자서 할 수 있는 작업 (코딩, 테스트, 설정)
- **human-task**: 사람이 직접 해야 하는 작업 (외부 서비스 가입, 앱스토어 등록)

작업 순서도 강제됩니다. 사람의 작업에 의존하지 않는 claude-task를 먼저 배치해서, 사람이 외부 서비스를 세팅하는 동안 AI가 할 수 있는 건 미리 다 해놓도록 합니다. 전체 리드타임을 최소화하기 위해서입니다.

### 5. 이슈 생성 — `/create-issues`

로드맵을 읽고 GitHub Issues를 자동으로 만들어줍니다. 에픽 이슈 아래에 하위 작업이 연결되고, claude-task/human-task 라벨이 자동으로 붙습니다.

### 6. 구현

여기서부터는 superpowers가 담당합니다. TDD, 서브에이전트 기반 개발, 체계적 디버깅 — 구현 품질에 관한 건 superpowers가 더 잘합니다.

커밋이나 PR 전에 `/code-review`를 실행하면, 변경된 코드가 프로젝트 규칙과 스택 베스트 프랙티스를 잘 지켰는지 크로스체크해줍니다. 무거운 4에이전트 병렬 리뷰가 아니라, 빠르고 실용적인 수준입니다.

---

## 전체 흐름 다이어그램

<img src="docs/diagrams/full-flow.png" alt="플러그인 설치부터 첫 배포까지" width="100%">

---

## 순서가 강제되는 원리

이 세팅의 핵심은 "다음에 뭘 해야 하는지 헷갈릴 일이 없다"는 것입니다. 몇 가지 장치로 이걸 보장합니다.

**산출물 기반 전제조건** — 각 스킬은 이전 스킬이 만든 파일이 존재하는지 확인합니다. 기획서 없이 디자인을 시작하려 하면, "먼저 `/app-plan`을 실행하세요"라고 안내하고 선택지를 줍니다. 급하면 `--skip`으로 건너뛸 수 있지만, 산출물에 "선행 단계를 건너뛰었습니다" 경고가 남습니다.

**디자인 스킬 강제 설치** — HTML을 생성하는 스킬 3개(design-system-to-figma, prd-to-figma, product-blueprint)는 실행 전에 frontend-design 스킬이 있는지 확인합니다. 없으면 자동 설치하고, 설치가 실패하면 중단합니다. 디자인 품질은 타협하지 않습니다.

**베스트 프랙티스 스킬 실시간 검색** — dev-plan에서 기술 스택이 정해지면 그 스택의 베스트 프랙티스 스킬을 검색해서 설치합니다. 정적 목록이 아니라 매번 최신 검색을 합니다. 이 단계는 건너뛸 수 없습니다.

**SSOT 변경 감지** — `docs/ssot/` 아래 파일이 수정되면 hook이 감지해서 "blueprint 업데이트가 필요합니다"라고 알려줍니다. 문서가 흩어지는 걸 방지합니다.

**대화 자동 기록** — 모든 대화가 `docs/sessions/`에 자동으로 저장됩니다. 세션이 끊겨도 맥락을 잃지 않습니다.

---

## 현황 확인

언제든 "현황 보여줘"라고 말하면 파이프라인 진행 상태를 확인할 수 있습니다.

```
> 현황 보여줘

[완료] 기획서 — docs/ssot/prd/2026-04-15-MyApp-기획서.md
[완료] 디자인 토큰 — docs/ssot/design/system/tokens.css
[미완] 화면 디자인 — 다음: /prd-to-figma
[미완] 개발 계획
[미완] 배포 로드맵
[미완] GitHub Issues
```

---

## 스킬 전체 목록

### 파이프라인 스킬 (순서대로 실행)

| 스킬 | 하는 일 | 만들어지는 것 |
|------|---------|-------------|
| `/app-plan` | 3인 에이전트 토론으로 기획 | 기획서(PRD), 유저플로우 HTML |
| `/design-system-to-figma` | 디자인 토큰 + 컴포넌트 시스템 생성 | `tokens.css`, `design-system.html` |
| `/prd-to-figma` | 기획서 화면 정의를 HTML로 변환 | 화면별 `screen-*.html` |
| `/dev-plan` | 기술 아키텍처 + 베스트 프랙티스 스킬 설치 | `dev-plan.md`, `architecture.html` |
| `/dev-roadmap` | 마일스톤별 로드맵 + 작업 분류 | `deploy-roadmap.md` |
| `/create-issues` | 로드맵 기반 GitHub 이슈 자동 생성 | GitHub Issues (에픽 + 하위) |
| `/code-review` | 커밋 전 규칙/베스트 프랙티스 크로스체크 | 리뷰 결과 보고 |

### 보조 스킬 (언제든 사용)

| 스킬 | 하는 일 |
|------|---------|
| `/product-blueprint` | 모든 SSOT 문서를 하나의 HTML로 통합 |
| `/handoff` | 세션 종료 시 맥락을 정리해서 문서로 남김 |
| `/resume` | 이전 세션의 맥락을 읽고 이어서 작업 |
| `/sync-roadmap` | GitHub 이슈 상태를 로드맵에 반영 |
| `/sync` | Git 원격 저장소 동기화 |
| `/clarify` | 모호한 요청을 인터뷰로 구체화 |

---

## 외부 플러그인 링크

| 플러그인 | 만든 사람 | 설명 |
|----------|----------|------|
| [slavingia/skills](https://github.com/slavingia/skills) | Sahil Lavingia (Gumroad 창업자) | validate-idea, mvp, pricing 등 스타트업 방법론 |
| [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | phuryn | PM 전문 100+ 스킬, 고객 인터뷰, 제품 디스커버리 |
| [superpowers](https://github.com/obra/superpowers) | Jesse Vincent | TDD, 서브에이전트 개발, 코드 리뷰, 체계적 디버깅 |
| [garrytan/gstack](https://github.com/garrytan/gstack) | Garry Tan (YC CEO) | autoplan, checkpoint 패턴, 23개 도구 스택 |
