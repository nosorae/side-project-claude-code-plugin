# Side Project Claude Settings

사이드 프로젝트를 **아이디어 → 기획 → 디자인 → 개발 계획 → 이슈 관리 → 구현**까지 Claude Code와 함께 진행하기 위한 규칙 + 스킬 모음.

---

## 어떻게 동작하나?

### 핵심 개념

이 레포는 **사이드 프로젝트 전용 워크플로우 템플릿**입니다. `/init-project`로 새 프로젝트를 만들면, 규칙과 스킬이 자동으로 복사되고 **`product-blueprint.html`(마스터 문서)**이 생성됩니다. 이후 각 파이프라인 스킬이 완료될 때마다 이 마스터 문서가 자동 업데이트되어, 프로젝트의 기획/디자인/개발 상태를 항상 한 곳에서 확인할 수 있습니다.

### 전체 파이프라인

> **[다이어그램 열기 (HTML)](docs/diagrams/pipeline.html)** — 브라우저에서 시각적 플로우차트 확인

| 순서 | 스킬 | 산출물 | 비고 |
|:---:|------|--------|------|
| 0 | `/interview` | `interview-notes.md` | 선택 — 아이디어가 구체적이면 생략 |
| 1 | `/app-plan` | PRD + 유저플로우 HTML | 에이전트 3인 토론으로 검증 |
| 2 | `/design-system-to-figma` | `tokens.css` + `design-system.html` | HTML 기본, Figma 선택 |
| 3 | `/prd-to-figma` | `screen-*.html` | tokens.css 선행 필요 |
| 4 | `/dev-plan` | `dev-plan.md` + 아키텍처 HTML | 플랫폼 스킬 자동 설치 |
| 5 | `/dev-roadmap` | `deploy-roadmap.md` + 타임라인 HTML | M0~M3 마일스톤 분류 |
| 6 | `/create-issues` | GitHub Issues | 에픽 + 하위 작업 자동 생성 |
| — | `/product-blueprint` | `product-blueprint.html` | 각 스킬 완료 시 자동 업데이트 (마스터 문서) |
| — | `/sync-roadmap` | 로드맵 업데이트 | 구현 중 수시 실행 |

### product-blueprint.html (마스터 문서)

`/init-project` 시점에 빈 껍데기로 생성되며, 각 파이프라인 스킬이 완료될 때마다 해당 탭이 자동으로 채워집니다.

| 탭 | 업데이트 시점 | 내용 |
|----|-------------|------|
| **기획** | `/app-plan` 완료 | MVP 범위, 핵심 기능, 유저 플로우 |
| **디자인 시스템** | `/design-system-to-figma` 완료 | 색상 토큰, 타이포, 컴포넌트 라이브러리 |
| **화면 디자인** | `/prd-to-figma` 완료 | 각 화면의 디자인 + PRD 요구사항을 나란히 표시 |
| **개발 계획** | `/dev-plan` 완료 | 아키텍처, 데이터 모델, API 설계 |
| **로드맵** | `/dev-roadmap` 완료 | 마일스톤별 진행률, claude-task/human-task 분류 |

> **이 파일 하나만 열면 프로젝트 전체 상태를 파악할 수 있습니다.**

### 사람과 AI의 역할 분담

| 단계 | 사람이 하는 일 | Claude Code가 하는 일 |
|------|---------------|---------------------|
| **프로젝트 시작** | `/init-project` 실행, 프로젝트 이름/설명 입력 | Git 초기화, GitHub 레포 생성, 규칙/스킬 복사, 라벨 생성 |
| **기획** | 앱 아이디어 설명, 에이전트 토론 결과 검토/판단 | 3인 에이전트 토론(시장성/경쟁/리스크), MVP 범위 설정, PRD 작성 |
| **디자인** | 디자인 결과물 리뷰, 수정 요청 | 디자인 토큰 생성, 컴포넌트 라이브러리 HTML, 화면별 디자인 HTML |
| **개발 계획** | 기술 스택 확인, 아키텍처 리뷰 | 디렉토리 구조, 데이터 모델, API 설계, 컴포넌트 정의 |
| **로드맵** | 마일스톤 순서/범위 확인 | 에픽 분류, claude-task/human-task 구분, 의존성 정의 |
| **이슈 생성** | 이슈 범위/분류 최종 확인 | GitHub Issues 자동 생성 (에픽 + 하위 작업) |
| **구현** | human-task 수행 (외부 서비스 설정 등), 코드 리뷰 | claude-task 이슈 독립 수행, 테스트 작성, 버그 수정 |
| **세션 관리** | 세션 종료 시 `/handoff` 요청 | 핸드오프 문서 작성, 다음 세션 `/resume`으로 상태 복구 |

### 작업 흐름 예시

> **[다이어그램 열기 (HTML)](docs/diagrams/workflow-example.html)** — 브라우저에서 세션별 타임라인 확인

<table>
<tr><th colspan="3">세션 1 — 기획 + 디자인</th></tr>
<tr><td>🧑</td><td><b>사람</b></td><td>"커플 메시지 앱 만들고 싶어"</td></tr>
<tr><td>🤖</td><td><code>/app-plan</code></td><td>에이전트 3명 토론 → MVP 범위 → PRD 작성</td></tr>
<tr><td>🧑</td><td><b>사람</b></td><td>토론 결과 리뷰, "진행하자" 판단</td></tr>
<tr><td>🤖</td><td><code>/design-system-to-figma</code></td><td>디자인 토큰 + 컴포넌트 생성</td></tr>
<tr><td>🤖</td><td><code>/prd-to-figma</code></td><td>화면별 디자인 HTML 생성</td></tr>
<tr><td>🧑</td><td><b>사람</b></td><td>디자인 리뷰, 수정 요청</td></tr>
<tr><td>🤖</td><td><code>/handoff</code></td><td>세션 정리</td></tr>
<tr><th colspan="3">세션 2 — 개발 준비</th></tr>
<tr><td>🤖</td><td><code>/resume</code></td><td>이전 세션 상태 파악</td></tr>
<tr><td>🤖</td><td><code>/dev-plan</code></td><td>기술 아키텍처 설계 + 플랫폼 스킬 설치</td></tr>
<tr><td>🧑</td><td><b>사람</b></td><td>아키텍처 리뷰</td></tr>
<tr><td>🤖</td><td><code>/dev-roadmap</code></td><td>마일스톤별 로드맵 생성</td></tr>
<tr><td>🤖</td><td><code>/create-issues</code></td><td>GitHub Issues 자동 생성</td></tr>
<tr><th colspan="3">세션 3~N — 구현</th></tr>
<tr><td>🤖</td><td><code>/resume</code></td><td>상태 파악, 우선순위 작업 제안</td></tr>
<tr><td>🧑</td><td><b>사람</b></td><td>"이슈 #15 해줘" (claude-task)</td></tr>
<tr><td>🤖</td><td><b>AI</b></td><td>이슈 본문 읽고 독립 구현 + 테스트</td></tr>
<tr><td>🧑</td><td><b>사람</b></td><td>human-task 수행 (Supabase 설정 등)</td></tr>
<tr><td>🤖</td><td><code>/handoff</code></td><td>세션 정리</td></tr>
</table>

---

## 생성되는 프로젝트 구조

`/init-project` 실행 후 새 프로젝트에 생성되는 구조:

```
my-project/
├── .claude/
│   ├── settings.json          # 대화 로깅 훅 설정
│   ├── rules/                 # 워크플로우 규칙 5개
│   │   ├── workflow.md        # 9개 작업 원칙 (요구사항 구체화, 계획 우선 등)
│   │   ├── ssot.md            # 문서 구조 + 스킬 파이프라인 정의
│   │   ├── github-issues.md   # 이슈 관리 (에픽/하위, claude-task/human-task)
│   │   ├── history.md         # 세션 핸드오프 정책
│   │   └── meta.md            # 규칙 파일 변경 시 사용자 확인 필수
│   └── skills/                # 스킬 7개
│       ├── app-plan/          # 4단계 앱 기획
│       ├── design-system-to-figma/  # 디자인 시스템 생성
│       ├── prd-to-figma/      # 화면별 디자인 생성
│       ├── dev-plan/          # 개발 계획서 작성
│       ├── dev-roadmap/       # 배포 로드맵 생성
│       ├── create-issues/     # GitHub Issues 자동 생성
│       └── handoff/           # 세션 핸드오프 문서 생성
├── hooks/
│   └── log-conversation.sh    # 대화 자동 로깅
├── docs/
│   ├── ssot/                  # 핵심 문서 (기획서, 디자인, 개발 계획 등)
│   ├── handoff/               # 세션 핸드오프 문서
│   ├── lessons/               # 교훈 기록 (자기개선 루프)
│   └── sessions/              # 대화 로그 (자동 생성)
└── (프로젝트 소스 코드)
```

### GitHub에 자동 생성되는 것들

- **라벨 3개**: `epic` (보라), `claude-task` (파랑), `human-task` (노랑)
- **에픽 이슈 6개**: 파이프라인 각 단계별 (기획서 → 디자인 시스템 → 화면 디자인 → 개발 계획 → 로드맵 → 이슈 생성)

---

## 규칙 5개

| 규칙 | 핵심 내용 |
|------|----------|
| **workflow** | 모호하면 물어보기, 계획 후 실행, 검증될 때까지 완료 아님, 최소한의 코드, 서브에이전트 활용 |
| **ssot** | 프로젝트 문서는 정해진 경로에만 저장, 스킬 간 의존성 명시, 문서 간 불일치 발견 시 알림 |
| **github-issues** | 에픽/하위 구조, claude-task는 이슈만 읽고 수행 가능하게, human-task는 초보도 따라할 수 있게 |
| **history** | 유의미한 작업 후 `/handoff`로 세션 정리, 10개 필수 섹션, 커밋+푸시 |
| **meta** | AI가 규칙 파일을 수정하려면 반드시 사용자 확인 후 |

---

## 스킬 목록

### 파이프라인 스킬 (순서대로 실행)

| 스킬 | 입력 | 출력 | 설명 |
|------|------|------|------|
| `/interview` | 앱 아이디어 (대략적) | `interview-notes.md` | 점진적 질문으로 요구사항 구체화 (선택, 생략 가능) |
| `/app-plan` | 앱 아이디어 | PRD + 유저플로우 HTML | 에이전트 토론으로 아이디어 검증 → MVP 범위 → 유저 플로우 |
| `/design-system-to-figma` | 기획서 | `tokens.css`, `design-system.html` | 디자인 토큰 + 컴포넌트 (HTML 기본, Figma 선택) |
| `/prd-to-figma` | 기획서 + tokens.css | `screen-*.html` | 화면별 디자인 HTML (HTML 기본, Figma 선택) |
| `/dev-plan` | 기획서 | `dev-plan.md` + 아키텍처 HTML | 기술 아키텍처 + 플랫폼 스킬 자동 설치 |
| `/dev-roadmap` | dev-plan.md | `deploy-roadmap.md` + 타임라인 HTML | M0~M3 마일스톤, claude-task/human-task 분류 |
| `/create-issues` | deploy-roadmap.md | GitHub Issues | 에픽 + 하위 작업 이슈 자동 생성 |

### 유틸리티 스킬

| 스킬 | 설명 |
|------|------|
| `/init-project` | 새 프로젝트 부트스트랩 (이 레포의 규칙/스킬을 새 프로젝트에 복사) |
| `/product-blueprint` | SSOT 통합 마스터 HTML (init-project에서 생성, 각 스킬 완료 시 자동 업데이트) |
| `/sync-roadmap` | GitHub Issues/PR 상태 기반 로드맵 문서 자동 최신화 |
| `/handoff` | 세션 종료 시 핸드오프 문서 생성 (10개 필수 섹션 + 커밋) |
| `/resume` | 새 세션에서 프로젝트 상태 파악 + 이어하기 |
| `/sync` | Git pull + 충돌 해결 + 최근 변경 내역 표시 |
| `/ideation` | 8개 에이전트로 수익성 있는 앱 아이디어 발굴 |

---

## 설치

### 방법 1: `/init-project` 스킬 (추천)

이 레포를 클론한 상태에서 Claude Code에 `/init-project` 실행:

```
> /init-project
프로젝트 이름: my-workout-app
공개 여부: private
설명: 운동 루틴 관리 앱
```

자동으로 디렉토리 생성, git init, GitHub 레포, 규칙/스킬 복사, 라벨 생성까지 완료.

### 방법 2: 수동 복사

```bash
SOURCE=~/side-project-claude-settings
TARGET=<프로젝트경로>

mkdir -p "$TARGET/.claude/rules" "$TARGET/.claude/skills"
cp "$SOURCE/rules/"*.md "$TARGET/.claude/rules/"
cp -r "$SOURCE/skills/app-plan" "$TARGET/.claude/skills/"
# ... 필요한 스킬만 선택 복사
```

### 방법 3: 심링크 (규칙 공유)

```bash
ln -s ~/side-project-claude-settings/rules <프로젝트>/.claude/rules
```

### 방법 4: 플러그인 설치 (스킬만)

```bash
claude plugin install --plugin-dir ~/side-project-claude-settings
```

---

## 스킬 의존성

> **[다이어그램 열기 (HTML)](docs/diagrams/dependencies.html)** — 브라우저에서 의존성 그래프 확인

<table>
<tr>
<th>스킬</th>
<th>선행 조건</th>
<th>분기</th>
</tr>
<tr><td><code>/interview</code></td><td>없음 (선택)</td><td rowspan="4">기획 + 디자인</td></tr>
<tr><td><code>/app-plan</code></td><td>아이디어</td></tr>
<tr><td><code>/design-system-to-figma</code></td><td>PRD</td></tr>
<tr><td><code>/prd-to-figma</code></td><td><code>tokens.css</code></td></tr>
<tr><td><code>/dev-plan</code></td><td>PRD</td><td rowspan="3">개발 + 배포</td></tr>
<tr><td><code>/dev-roadmap</code></td><td><code>dev-plan.md</code></td></tr>
<tr><td><code>/create-issues</code></td><td><code>deploy-roadmap.md</code> + GitHub</td></tr>
<tr><td><code>/product-blueprint</code></td><td>SSOT 문서 1개 이상</td><td rowspan="2">유틸리티 (언제든)</td></tr>
<tr><td><code>/sync-roadmap</code></td><td><code>deploy-roadmap.md</code> + GitHub</td></tr>
</table>

- `/interview`는 선택사항 — 아이디어가 구체적이면 바로 `/app-plan` 시작
- `design-system-to-figma`과 `prd-to-figma`는 HTML 생성이 기본, Figma 내보내기는 선택
- `dev-plan` 실행 시 tech stack에 맞는 플랫폼 스킬 자동 검색/설치
- `create-issues`는 GitHub 레포 연결 필수
