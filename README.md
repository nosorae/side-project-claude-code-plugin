# Side Project Claude Settings

사이드 프로젝트를 **아이디어 → 기획 → 디자인 → 개발 계획 → 이슈 관리 → 구현**까지 Claude Code와 함께 진행하기 위한 규칙 + 스킬 모음.

`/init-project`로 새 프로젝트를 만들면 플러그인이 설치되어 규칙/스킬이 자동 적용되고, **`product-blueprint.html`(마스터 문서)**이 생성됩니다. 각 스킬이 완료될 때마다 마스터 문서가 자동 업데이트되어 프로젝트 전체 상태를 한 곳에서 확인할 수 있습니다.

## 설치

```
> /init-project
```

프로젝트 이름, 공개 여부, 설명만 입력하면 Git 초기화, GitHub 레포 생성, 플러그인 설치(규칙 8개 + 스킬 16개), develop 브랜치 생성, 라벨 생성까지 자동 완료. 훅 2개도 함께 설치됩니다:
- `log-conversation.sh` — 모든 대화가 `docs/sessions/`에 자동 저장
- `remind-blueprint-update.sh` — SSOT 문서 변경 시 블루프린트 업데이트 리마인드

---

## init-project부터 첫 배포까지

<img src="docs/diagrams/full-flow.png" alt="init-project부터 첫 배포까지 전체 흐름" width="100%">

---

## 사람과 AI의 역할 분담

<img src="docs/diagrams/workflow-example.png" alt="작업 흐름 예시" width="100%">

| 단계 | 사람 | Claude Code |
|------|------|-------------|
| **시작** | `/init-project` 실행 | Git/GitHub 초기화, 플러그인 설치, develop 브랜치, 라벨 생성 |
| **시장 조사** | 아이디어 설명 (선택) | 3인 에이전트 토론으로 시장성 검증 |
| **기획** | 결과 판단, 방향 결정 | 핵심 가치 정의, MVP 범위, PRD 작성 |
| **디자인** | 리뷰, 수정 요청 | 디자인 토큰, 컴포넌트, 화면별 HTML |
| **개발 계획** | 아키텍처 리뷰 | 기술 설계, 플랫폼 스킬 자동 설치 |
| **구현** | human-task 수행, 코드 리뷰 | claude-task 독립 수행, 테스트, 버그 수정 |
| **세션 관리** | `/handoff` 요청 | 핸드오프 문서 → `/resume`으로 복구 |

---

## 스킬 목록

### 파이프라인 스킬

| 스킬 | 산출물 | 설명 |
|------|--------|------|
| `/interview` | `interview-notes.md` | 점진적 질문으로 요구사항 구체화 (선택) |
| `/market-research` | `*-시장조사.md` | 3인 에이전트 토론으로 시장성 검증 (선택) |
| `/app-plan` | PRD + 유저플로우 HTML | 핵심 가치 → MVP 범위 → 유저 플로우 → PRD |
| `/design-system-to-figma` | `tokens.css` + `design-system.html` | 디자인 토큰 + 컴포넌트 (HTML 기본, Figma 선택) |
| `/prd-to-figma` | `screen-*.html` | 화면별 디자인 HTML (tokens.css 선행 필요) |
| `/dev-plan` | `dev-plan.md` + 아키텍처 HTML | 기술 아키텍처 + 베스트 프랙티스 스킬 필수 설치 |
| `/dev-roadmap` | `deploy-roadmap.md` + 타임라인 HTML | M0~M3 마일스톤, claude-task/human-task 분류 |
| `/create-issues` | GitHub Issues | 에픽 + 하위 작업 자동 생성 |

### 세션 관리 스킬 (중간중간 사용)

| 스킬 | 설명 |
|------|------|
| `/handoff` | 세션 종료 시 핸드오프 문서 생성 (10개 필수 섹션 + 커밋) |
| `/resume` | 새 세션 시작 시 프로젝트 상태 파악 + 이어하기 |

### 유틸리티 스킬

| 스킬 | 설명 |
|------|------|
| `/init-project` | 새 프로젝트 부트스트랩 (플러그인 설치 + Git Flow) |
| `/product-blueprint` | SSOT 통합 마스터 HTML (각 스킬 완료 시 자동 업데이트) |
| `/sync-roadmap` | GitHub Issues 상태 기반 로드맵 최신화 |
| `/sync` | Git pull + 충돌 해결 |
| `/ideation` | 8개 에이전트로 앱 아이디어 발굴 |
| `/clarify` | 모호한 이슈/요청을 인터뷰로 구체화 |

---

## 규칙 8개

| 규칙 | 핵심 |
|------|------|
| **pipeline** | 파이프라인 순서 강제, 산출물 기반 전제조건, --skip 옵션, 현황 조회 |
| **workflow** | 모호하면 clarify 패턴으로 구체화, 계획 후 실행, 검증될 때까지 완료 아님 |
| **ssot** | 문서는 정해진 경로에만, 스킬 간 의존성 명시 |
| **github-issues** | 에픽/하위 구조, claude-task/human-task 라벨 |
| **history** | `/handoff`로 세션 정리, 10개 필수 섹션 |
| **meta** | 규칙 변경 시 사용자 확인 필수 |
| **source-citation** | 소스 등급제 (Tier 1/2/3), 낮은 등급은 교차검증 필수 |
| **git-flow** | main + develop + feature/ + fix/, main은 PR로만 병합 |
