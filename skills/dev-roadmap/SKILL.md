---
name: dev-roadmap
description: |
  개발 계획서를 기반으로 마일스톤별 배포 로드맵을 생성하는 스킬. 에픽 분류, claude-task/human-task 구분, 의존성 순서를 정의한다.
  이 스킬은 다음과 같은 요청에 반드시 사용한다: "로드맵 만들어줘", "배포 계획", "마일스톤 정리", "개발 일정", "릴리스 계획", "/dev-roadmap".
  개발 계획이나 일정, 마일스톤 관련 맥락이면 이 스킬을 사용한다.
user_invocable: true
---

# Dev Roadmap (배포 로드맵 생성)

개발 계획서(`docs/ssot/dev/dev-plan.md`)를 분석하여 마일스톤별 배포 로드맵(`docs/ssot/dev/deploy-roadmap.md`)을 생성하는 스킬입니다.

> **도식화는 반드시 HTML/CSS로 생성한다. 아스키아트, 머메이드 금지.**

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "로드맵 만들어줘", "배포 계획 세워줘"
- "/dev-roadmap"
- "개발 계획은 있는데 순서를 정해야 해"

## 전제조건

- `docs/ssot/dev/dev-plan.md` 파일이 존재해야 한다
- **없으면**:
  ```
  ⚠️ 이 스킬을 실행하려면 먼저 `/dev-plan`으로 개발 계획서를 작성해야 합니다.
  현재 docs/ssot/dev/dev-plan.md 파일이 없습니다.

  선택하세요:
  a) /dev-plan 먼저 실행 (권장)
  b) --skip으로 전제조건 건너뛰고 진행 (비권장)
  ```
- `--skip` 선택 시 → 산출물에 스킵 경고 표시

## 실행 단계

### Step 1: 개발 계획서 분석

**Actions:**

1. `docs/ssot/dev/dev-plan.md`를 읽고 다음을 파악한다:
   - 기술 스택과 외부 서비스 의존성
   - 데이터 모델과 API 엔드포인트
   - 핵심 컴포넌트와 화면 목록
2. 기획서(PRD)도 함께 참조하여 MVP 범위와 타임라인을 확인한다

### Step 2: 마일스톤 및 에픽 구성

**Actions:**

1. 작업을 마일스톤으로 분류한다:
   - **M0: 프로젝트 셋업** — 초기 환경 구성, 외부 서비스 설정
   - **M1: 핵심 기능** — MVP의 핵심 가치를 전달하는 기능
   - **M2: 보조 기능** — MVP 완성에 필요한 나머지 기능
   - **M3: 마무리** — 테스트, 버그 수정, 배포

2. 각 마일스톤 내에서 에픽을 정의한다:
   - 에픽 이름과 설명
   - 에픽 내 하위 작업 목록

3. 각 작업을 분류한다:
   - `claude-task`: Claude Code가 코드 작성/수정으로 독립 수행 가능
   - `human-task`: 외부 서비스 설정, 계정 생성, 결제, 수동 테스트 등 사람이 직접 수행

4. 의존성 순서를 정의한다:
   - 어떤 작업이 다른 작업보다 먼저 완료되어야 하는지
   - 병렬 수행 가능한 작업 그룹

5. **작업 배치 순서 원칙** (필수):
   - **1순위**: human-task에 의존하지 않는 독립 claude-task → 가장 앞에 배치 (즉시 병렬 수행 가능)
   - **2순위**: human-task → 사람이 처리하는 동안 1순위 작업과 병렬 진행
   - **3순위**: human-task에 의존하는 claude-task → human-task 완료 후 수행
   - 이유: claude-task가 먼저 끝나 있으면 human-task 완료 즉시 다음 단계로 진입 가능하여 전체 리드타임을 최소화한다

### Step 3: 문서 생성 및 저장

**Actions:**

1. `docs/ssot/dev/deploy-roadmap.md` 파일 생성
2. 다음 구조로 작성:

```markdown
# [앱 이름] 배포 로드맵

> **개발 계획서**: docs/ssot/dev/dev-plan.md
> **작성일**: YYYY-MM-DD
> **목표**: MVP 배포

## 전체 흐름

마일스톤 타임라인을 HTML/CSS로 시각화하여 `docs/ssot/dev/roadmap-visual.html` 파일로 저장한다.
- 각 마일스톤을 타임라인 노드로 표현하고, 에픽/작업을 하위 항목으로 시각화
- 의존성과 진행 순서를 화살표로 연결
- 브라우저에서 바로 열어볼 수 있는 standalone HTML 파일로 작성

## M0: 프로젝트 셋업

### Epic: 개발 환경 구성

> **배치 원칙**: 독립 claude-task → human-task → 의존 claude-task 순서

| # | 작업 | 타입 | 의존성 | 비고 |
|---|------|------|--------|------|
| 1 | 프로젝트 초기화 | claude-task | - | 즉시 수행 가능 |
| 2 | 기본 구조 및 보일러플레이트 생성 | claude-task | - | 즉시 수행 가능 |
| 3 | Supabase 프로젝트 생성 | human-task | - | #1, #2와 병렬 진행 |
| 4 | 환경변수 설정 | claude-task | #3 | human-task 완료 후 |

## M1: 핵심 기능
[에픽별 작업 테이블]

## M2: 보조 기능
[에픽별 작업 테이블]

## M3: 마무리
[에픽별 작업 테이블]

## 다음 단계
- [ ] `/create-issues`로 GitHub Issues 생성
```

3. Git 커밋 + 푸시

#### product-blueprint 자동 업데이트

product-blueprint.html의 로드맵 탭을 자동 업데이트한다. `/product-blueprint --tab=로드맵` 실행.

### Step 4: 최종 리뷰

**Actions:**

1. 생성된 `docs/ssot/dev/deploy-roadmap.md`의 마일스톤/에픽 구조를 요약하여 사용자에게 보여준다
2. **사용자 확인**: "배포 로드맵을 생성했습니다. 수정이 필요한 부분이 있으면 말씀해주세요."

**Expected Output:**
마일스톤/에픽/작업 구조, claude-task/human-task 분류, 의존성 순서가 포함된 `docs/ssot/dev/deploy-roadmap.md` + 마일스톤 타임라인 `docs/ssot/dev/roadmap-visual.html`

---

## 모델 선택 가이드

- 개발 계획서 분석 + 마일스톤 구성: `opus` (의존성 판단, 작업 분류)
- 문서 구조화 + 저장: `sonnet` (구조화된 문서 작성)

---

## 분류 기준

### claude-task로 분류되는 작업
- 프로젝트 초기화 (프레임워크 셋업, 보일러플레이트)
- 컴포넌트/페이지 구현
- API 엔드포인트 구현
- DB 스키마/마이그레이션 작성
- 테스트 코드 작성
- 버그 수정
- CI/CD 설정 파일 작성

### human-task로 분류되는 작업
- 외부 서비스 계정 생성 (Supabase, Firebase, Vercel 등)
- OAuth 앱 등록 (Google, Apple 등)
- 도메인 구매/DNS 설정
- 앱스토어 등록/심사
- 결제 시스템 설정 (Stripe 등)
- 수동 QA/사용성 테스트
- 디자인 에셋 최종 확인

---

## 품질 체크리스트

- [ ] 개발 계획서의 모든 컴포넌트가 작업으로 분해되었는가?
- [ ] 의존성 순서가 논리적인가? (DB 스키마 → API → UI 순)
- [ ] human-task가 병목이 되지 않도록 앞쪽에 배치되었는가?
- [ ] 각 마일스톤이 독립적으로 검증 가능한가?
- [ ] 마일스톤 간 의존성이 논리적인가?

---

## 관련 스킬

- `dev-plan` - 개발 계획서 작성 (선행)
- `create-issues` - GitHub Issues 생성 (후행)
