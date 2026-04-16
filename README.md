# Side Project Claude Code Plugin

사이드 프로젝트할 때 쓰는 Claude Code 세팅입니다.

아이디어 검증 → 기획 → 디자인 → 개발 계획 → 이슈 관리 → 구현까지, 다음에 뭘 해야 하는지 순서대로 안내해줍니다. 직접 만든 스킬과 잘 만들어진 외부 플러그인을 조합해서 씁니다.

> 공사중
> 현재 플러그인 설치/로딩 경로를 정리하는 중입니다. README의 설치 절차는 추가 테스트가 필요하며, 동작이 환경에 따라 달라질 수 있습니다.

---

## 설치

```bash
claude plugin marketplace add nosorae/side-project-claude-settings --scope user
claude plugin install side-project-claude-code-plugin@side-project-claude-settings --scope project
```

처음 한 번은 marketplace를 추가해야 합니다. 그 다음부터는 설치 명령만 다시 실행하면 됩니다. 필요한 동반 플러그인 4개는 첫 사용 시 자동으로 설치됩니다.

---

## 첫 셋업: `/init-project`

플러그인 설치 직후 한 번 실행하세요. **이거 안 하면 `/app-plan`이 제대로 동작하지 않습니다.**

```
나: /init-project
```

플러그인은 `skills/`와 `hooks/`만 로드합니다. 그 외에 파이프라인이 돌아가는 데 필요한 환경 — 워크플로우 규칙(`.claude/rules/`), `docs/` 디렉토리 구조, `product-blueprint.html`, GitHub 라벨/마일스톤/인프라(`pr-check.yml`, `pre-push` hook), 에픽 이슈 7개 — 은 `/init-project`가 한번에 셋업합니다.

> **왜 따로 실행해야 하나?** Claude Code 플러그인 시스템은 path traversal 제약 때문에 사용자 프로젝트에 임의 파일을 자동 배포할 수 없습니다 ([공식 docs](https://code.claude.com/docs/en/plugins-reference.md)). 그래서 plugin install 직후 한 번 `/init-project`로 환경을 깔아주는 단계가 필요합니다.

**`/init-project`가 묻는 것 (4가지):**
1. 프로젝트 이름 (kebab-case)
2. 프로젝트 경로 (기본 `~/side-project-{이름}`)
3. GitHub 공개 여부 (기본 private)
4. 한 줄 설명

**`/init-project`가 자동으로 하는 것:**
- `git init` + `gh repo create` + `develop` 브랜치
- `.claude/rules/` 복사 (플러그인 캐시 → 프로젝트)
- `docs/ssot/`, `docs/refs/`, `docs/handoff/`, `docs/lessons/`, `docs/sessions/` 생성
- `product-blueprint.html` 5탭 스켈레톤 생성
- GitHub 인프라 복사 (`.github/workflows/pr-check.yml`, 이슈 템플릿, `.git/hooks/pre-push`)
- 라벨 3개 (`epic`, `claude-task`, `human-task`) + 마일스톤 `v0.1.0`
- 에픽 이슈 7개 자동 생성
- Branch protection (가능한 경우)

---

## 무료 GitHub 계정 제약

GitHub Free 플랜 + private 레포 조합은 **branch protection을 설정할 수 없습니다** (GitHub Pro 이상 필요). `/init-project`는 이 조합을 감지하면 branch protection 단계를 자동 스킵하고 안내 메시지를 출력합니다.

| 조합 | branch protection | 대응 |
|------|------------------|------|
| Free + public | ✅ 가능 | 자동 설정 |
| Free + private | ❌ 불가 | 스킵 + 안내 (public 변경 또는 Pro 업그레이드) |
| Pro 이상 | ✅ 가능 | 자동 설정 |

**branch protection 없이도 작동하는 강제 메커니즘:**
- `pr-check.yml` (PR 체크 액션) — 무료 + private에서도 동작
- `.git/hooks/pre-push` — 로컬에서 커밋 메시지 `#N` 강제, 모든 환경에서 동작

즉, branch protection이 빠져도 PR 흐름은 깨지지 않습니다. 다만 main 직접 push가 GitHub 측에서 막히지는 않으므로, `git-flow.md` 규칙을 사람이 의식적으로 지키거나 Pro 업그레이드를 권장합니다.

---

## 설치하면 일어나는 일

플러그인 설치 + `/init-project` 후 프로젝트에 다음이 준비됩니다:

- 기획부터 이슈 생성까지 이어지는 **파이프라인 스킬 8개**
- 아이디어 검증, PM, 구현, 작업 관리를 위한 **동반 플러그인 4개** (자동 설치)
- 대화를 자동 기록하는 **hook**
- 문서가 바뀌면 알려주는 **변경 감지 hook**
- 워크플로우 규칙 (`.claude/rules/`)
- GitHub 인프라 (PR 체크, 이슈 템플릿, pre-push hook)
- 에픽 이슈 7개 + 라벨 + 마일스톤 `v0.1.0`

---

## 전체 흐름

각 단계에서 사람이 뭘 하고, Claude가 뭘 하는지 같이 적었습니다.

### 1. 아이디어 검증

> 만들기 전에 검증부터 하는 게 좋습니다. 선택 단계라 건너뛰어도 됩니다.

```
나: 운동 루틴 공유 앱 아이디어가 있는데, 해볼 만한지 검증해줘
```

**Claude가 하는 일:**
[slavingia/skills](https://github.com/slavingia/skills)의 `validate-idea`가 Mom Test 방식으로 검증하고 Lean Canvas를 만들어줍니다. 고객 인터뷰가 필요하면 [phuryn/pm-skills](https://github.com/phuryn/pm-skills)를 씁니다.

**사람이 하는 일:** 결과를 보고 진행할지 판단합니다.

---

### 2. 기획

```
나: 앱 기획해줘
```

**Claude가 하는 일:**
IDEO의 Design Thinking 3 Lenses 프레임워크로 분석합니다. 팀메이트 3명이 각자 독립 세션에서 조사합니다.
- **Desirability**: 사용자가 진짜 원하는 게 뭔지
- **Viability**: 수익 모델은 뭐가 맞는지
- **Feasibility**: AI 코딩으로 만들 수 있는지

각자 웹 검색까지 해서 조사한 다음, 세 렌즈의 교집합에서 핵심 가치, MVP 범위, 유저 플로우를 정하고 기획서(PRD)를 씁니다.

**사람이 하는 일:** 기획서를 읽고, 방향이 맞는지 판단합니다. 수정할 부분이 있으면 말하면 됩니다.

**이 기획서가 이후 모든 단계의 출발점입니다.** 기획서 없이 디자인을 시작하려 하면 "먼저 기획서를 작성하세요"라고 안내합니다.

---

### 3. 디자인

```
나: 디자인 시스템 만들어줘
```

**Claude가 하는 일:**
기획서를 읽고, 앱 성격에 맞는 디자인 토큰(색상, 타이포, 간격)을 생성합니다. 금융 앱이면 블루, 음식 앱이면 오렌지 계열로. 그 토큰으로 버튼, 입력 필드, 카드, 네비게이션 같은 컴포넌트를 HTML로 만듭니다.

```
나: 화면 디자인해줘
```

기획서의 화면 정의를 읽고, 각 화면을 모바일 크기(390x844) HTML로 만듭니다. 브라우저에서 바로 열어볼 수 있습니다.

**사람이 하는 일:** 브라우저에서 디자인을 확인하고, 수정 요청을 합니다. "이 버튼 좀 더 크게", "색상 바꿔줘" 같은 식으로.

디자인 품질을 위해 `frontend-design` 스킬이 없으면 자동 설치됩니다. 실패하면 멈춥니다. 디자인 원칙 없이 만들면 "AI가 만든 티"가 나기 때문입니다.

---

### 4. 개발 계획

```
나: 개발 계획 세워줘
```

**Claude가 하는 일:**
기획서와 디자인을 분석해서 기술 아키텍처, 디렉토리 구조, 데이터 모델, API를 설계합니다.

기술 스택이 정해지면, 그 스택의 **베스트 프랙티스 스킬을 실시간 검색**해서 설치합니다. 6개월 전에 좋았던 스킬이 지금은 관리 안 될 수 있으니, 정적 목록이 아니라 매번 최신을 찾습니다. 이 단계는 건너뛸 수 없습니다.

**사람이 하는 일:** 아키텍처를 리뷰합니다. 기술 스택이나 구조에 의견이 있으면 반영합니다.

---

### 5. 배포 로드맵

```
나: 로드맵 만들어줘
```

**Claude가 하는 일:**
개발 계획을 릴리스 버전(v0.1.0, v0.2.0, v1.0.0...)으로 나누고, 각 작업을 분류합니다:
- **claude-task**: AI가 혼자 할 수 있는 것 (코딩, 테스트, 설정)
- **human-task**: 사람이 해야 하는 것 (외부 서비스 가입, 앱스토어 등록)

작업 순서를 자동으로 최적화합니다. 사람 작업에 의존하지 않는 claude-task를 먼저 배치해서, 사람이 Supabase를 세팅하는 동안 AI가 할 수 있는 건 미리 다 해놓습니다.

**사람이 하는 일:** 로드맵을 확인하고, 우선순위를 조정합니다.

---

### 6. 이슈 생성

```
나: 이슈 만들어줘
```

**Claude가 하는 일:**
로드맵을 읽고 GitHub Issues를 자동으로 만듭니다. 에픽 이슈 아래에 하위 작업이 연결되고, claude-task/human-task 라벨이 붙습니다. claude-task에는 어떤 AI가 봐도 동일하게 구현할 수 있을 만큼 명확한 스펙이, human-task에는 따라하기 쉬운 스텝바이스텝 가이드가 들어갑니다.

**사람이 하는 일:** 이슈 구조를 확인하고 승인합니다. 자동으로 만들되, 최종 판단은 사람이 합니다.

---

### 7. 구현

[superpowers](https://github.com/obra/superpowers)와 [garrytan/gstack](https://github.com/garrytan/gstack)이 구현을 담당합니다.

**Claude가 하는 일 (claude-task):** 설계 검토 → 작업 분할 → 서브에이전트 병렬 개발 → TDD → 코드 리뷰

**사람이 하는 일 (human-task):** 외부 서비스 세팅, PR 리뷰, 수동 QA

사람이 human-task를 처리하는 동안 Claude는 다음 claude-task를 미리 진행합니다.

---

### 8. 첫 배포

모든 마일스톤이 끝나면 develop에서 main으로 PR을 만들고, 빌드와 테스트를 통과하면 배포합니다.

---

## 배포 이후

- **세션 관리**: 대화가 `docs/sessions/`에 자동 저장됩니다. 세션이 끊겨도 superpowers가 이전 맥락을 이어갑니다.
- **버그 수정**: superpowers의 체계적 디버깅이 증상→가설→원인→수정→검증 순서로 처리합니다.
- **기능 추가**: 기획서를 업데이트하고 같은 파이프라인을 다시 탑니다. 문서가 바뀌면 hook이 블루프린트 업데이트를 알려줍니다.
- **현황 확인**: "현황 보여줘"로 파이프라인 상태를 확인합니다. `/product-blueprint`로 전체 문서를 하나의 HTML로 봅니다.

---

## 전체 흐름 다이어그램

<img src="docs/diagrams/full-flow.png" alt="전체 흐름" width="100%">

---

## 사람과 Claude의 역할 정리

| 단계 | 사람이 하는 것 | Claude가 하는 것 |
|------|-------------|----------------|
| 아이디어 검증 | 아이디어를 설명한다 | Mom Test, Lean Canvas로 검증한다 |
| 기획 | 방향을 판단하고 수정한다 | Design Thinking 3 Lenses 팀메이트 토론으로 PRD를 작성한다 |
| 디자인 | 브라우저에서 확인하고 피드백한다 | 토큰, 컴포넌트, 화면 HTML을 만든다 |
| 개발 계획 | 아키텍처를 리뷰한다 | 기술 설계 + 베스트 프랙티스 스킬을 설치한다 |
| 로드맵 | 우선순위를 조정한다 | 마일스톤 분류, 작업 순서 최적화를 한다 |
| 이슈 생성 | 구조를 승인한다 | GitHub Issues를 자동 생성한다 |
| 구현 | human-task 수행, PR 리뷰 | claude-task 구현, TDD, 코드 리뷰 |
| 유지보수 | 버그 보고, 기능 요청 | 체계적 디버깅, 파이프라인 재실행 |

사람은 판단하고, Claude는 실행합니다.

---

## 순서가 알아서 잡히는 원리

각 스킬은 이전 스킬이 만든 파일이 있는지 확인합니다. 기획서가 없으면 디자인을 시작할 수 없고, 디자인 토큰이 없으면 화면을 만들 수 없습니다. 순서를 건너뛰려 하면 "먼저 이걸 하세요"라고 안내하고, 정말 건너뛰고 싶으면 `--skip` 옵션도 있지만 결과물에 경고가 남습니다.

디자인 품질을 위한 스킬 설치, 개발 스택 베스트 프랙티스 스킬 설치, 로드맵 작업 순서 최적화 — 이런 건 스킵 옵션 없이 강제됩니다.

---

## 사용하는 플러그인들

| 플러그인 | 만든 사람 | 주로 쓰는 시점 |
|----------|----------|--------------|
| [slavingia/skills](https://github.com/slavingia/skills) | Sahil Lavingia (Gumroad 창업자) | 아이디어 검증, MVP 정의, 가격 책정 |
| [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | phuryn | 고객 인터뷰, 제품 디스커버리, 우선순위 |
| **이 플러그인** | nosorae | 기획 → 디자인 → 개발 계획 → 로드맵 → 이슈 |
| [superpowers](https://github.com/obra/superpowers) | Jesse Vincent | 구현: TDD, 서브에이전트 개발, 코드 리뷰, 디버깅 |
| [garrytan/gstack](https://github.com/garrytan/gstack) | Garry Tan (YC CEO) | 큰 작업 자동 분할, 체크포인트 관리 |
