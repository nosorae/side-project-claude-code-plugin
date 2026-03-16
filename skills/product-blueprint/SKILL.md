---
description: PRD, 디자인, 개발 계획 등 SSOT 문서를 하나의 인터랙티브 HTML로 통합하는 마스터 문서 생성 스킬
user_invocable: true
---

# Product Blueprint (제품 청사진)

모든 SSOT 문서(기획서, 디자인 토큰, 화면 디자인, 개발 계획, 배포 로드맵)를 하나의 인터랙티브 HTML 파일로 통합하는 마스터 문서를 생성합니다.

**생성 파일**: `docs/ssot/product-blueprint.html`

> **중요**: `product-blueprint.html`은 모든 SSOT 문서보다 우선하는 MASTER 문서입니다. 문서 간 불일치가 있으면 이 파일의 내용이 최종 기준입니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "제품 청사진 만들어줘", "블루프린트 생성"
- "/product-blueprint"
- "SSOT 문서 통합해줘", "마스터 문서 만들어줘"
- SSOT 문서가 생성/수정된 후 통합 뷰가 필요할 때

## 전제조건

- 아래 SSOT 문서 중 **최소 1개 이상** 존재해야 한다:
  - `docs/ssot/prd/*.md` (기획서)
  - `docs/ssot/design/system/tokens.css` (디자인 토큰)
  - `docs/ssot/design/screens/screen-*.html` (화면 디자인)
  - `docs/ssot/dev/dev-plan.md` (개발 계획)
  - `docs/ssot/dev/deploy-roadmap.md` (배포 로드맵)
- 어떤 SSOT 문서도 존재하지 않으면 실행을 거부하고, `/app-plan` 스킬을 먼저 실행하도록 안내한다

## 실행 단계

### Step 1: SSOT 문서 스캔

**Actions:**

1. 아래 경로를 순서대로 탐색하여 존재하는 문서를 목록화한다:
   - `docs/ssot/prd/*.md` → 기획 탭 콘텐츠
   - `docs/ssot/design/system/tokens.css` → 디자인 탭 (토큰 섹션)
   - `docs/ssot/design/screens/screen-*.html` → 디자인 탭 (화면 프리뷰 섹션)
   - `docs/ssot/dev/dev-plan.md` → 개발 탭 콘텐츠
   - `docs/ssot/dev/deploy-roadmap.md` → 로드맵 탭 콘텐츠

2. 존재하지 않는 문서는 해당 탭에 "아직 생성되지 않음 — [스킬명]으로 생성하세요" 안내를 표시한다

3. 사용자에게 스캔 결과를 보여주고 진행 여부를 확인한다:
   - "다음 문서를 발견했습니다: [목록]. 블루프린트를 생성할까요?"

### Step 2: 콘텐츠 추출 및 변환

**Actions:**

1. **기획서 (PRD)**
   - 마크다운 파일을 읽어 핵심 섹션(앱 개요, 핵심 기능, 유저 플로우, 화면 목록)을 HTML로 변환한다
   - 마크다운 헤딩을 HTML 헤딩으로, 리스트를 HTML 리스트로, 테이블을 HTML 테이블로 변환한다

2. **디자인 토큰**
   - `tokens.css`에서 CSS 변수를 파싱하여 색상 팔레트, 타이포그래피, 간격 등을 시각적 프리뷰로 렌더링한다
   - 색상은 견본(swatch)으로, 타이포그래피는 실제 폰트 적용 예시로 표시한다

3. **화면 디자인**
   - `screen-*.html` 파일들을 `<iframe>` 또는 인라인 삽입으로 프리뷰한다
   - 파일명에서 화면 이름을 추출하여 라벨로 표시한다 (예: `screen-home.html` → "홈 화면")

4. **개발 계획**
   - `dev-plan.md`에서 기술 스택, 디렉토리 구조, 데이터 모델, API 설계를 HTML로 변환한다

5. **배포 로드맵**
   - `deploy-roadmap.md`에서 마일스톤과 작업 항목을 추출한다
   - 체크박스(`- [ ]`, `- [x]`)를 파싱하여 진행률 바를 계산·표시한다

### Step 3: HTML 문서 생성

**Actions:**

1. `docs/ssot/product-blueprint.html` 파일을 생성한다
2. 다음 구조로 작성한다:

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[앱 이름] — 제품 청사진</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- 인라인 스타일: tokens.css 변수 포함 -->
</head>
<body>
  <!-- 헤더: 앱 이름 + 생성 일시 -->
  <!-- 탭 네비게이션: 기획 | 디자인 | 개발 | 로드맵 | 유저플로우 -->
  <!-- 탭 콘텐츠 패널 -->
</body>
</html>
```

3. **HTML 요구사항:**

   **탭 구성:**
   | 탭 이름 | 소스 문서 | 표시 내용 |
   |---------|----------|----------|
   | 기획 | `prd/*.md` | 앱 개요, 핵심 기능, 타겟 사용자, MVP 범위 |
   | 디자인 | `tokens.css` + `screen-*.html` | 토큰 시각화 + 화면 프리뷰 (iframe) |
   | 개발 | `dev-plan.md` | 기술 스택, 디렉토리 구조, 데이터 모델, API |
   | 로드맵 | `deploy-roadmap.md` | 마일스톤별 진행률 바 + 작업 체크리스트 |
   | 유저플로우 | `prd/*.md`에서 추출 | 화면 간 이동 흐름을 시각적 다이어그램으로 표시 |

   **레이아웃:**
   - 모바일 퍼스트 반응형 (기준 뷰포트: 390px)
   - 탭 전환은 JavaScript로 구현 (페이지 리로드 없이)
   - 화면 프리뷰는 카드 그리드 레이아웃 (모바일 1열, 데스크탑 2-3열)

   **스타일:**
   - Tailwind CSS CDN 사용 (외부 의존성은 이것만 허용)
   - 다크모드 미지원 (라이트 모드 전용)
   - 폰트: 시스템 폰트 스택 사용
   - 모든 텍스트는 한국어 실제 내용, 플레이스홀더 텍스트(lorem ipsum 등) 사용 금지

   **인터랙션:**
   - 탭 전환 시 URL 해시 업데이트 (`#기획`, `#디자인` 등)
   - 페이지 로드 시 URL 해시에 해당하는 탭 자동 활성화
   - 로드맵 탭의 진행률은 체크된 항목 수 / 전체 항목 수로 자동 계산

### Step 4: 커밋 및 푸시

**Actions:**

1. `docs/ssot/product-blueprint.html` 파일을 Git에 커밋한다
2. 커밋 메시지: `Docs: 제품 청사진(product-blueprint.html) 생성` (신규) 또는 `Docs: 제품 청사진 업데이트` (갱신)
3. 원격 저장소에 푸시한다

### Step 5: 최종 리뷰

**Actions:**

1. 생성된 블루프린트의 탭별 콘텐츠 요약을 사용자에게 보여준다:
   - 기획: 핵심 기능 N개, 화면 N개
   - 디자인: 토큰 N개, 화면 프리뷰 N개
   - 개발: 기술 스택 요약
   - 로드맵: 마일스톤 N개, 전체 진행률 N%
   - 유저플로우: 플로우 N개
2. "제품 청사진을 생성했습니다. 브라우저에서 확인해주세요: `docs/ssot/product-blueprint.html`"

**Expected Output:**
모든 SSOT 문서가 탭별로 통합된 `docs/ssot/product-blueprint.html`

---

## 실행 모드

### 전체 생성 모드 (기본)

인자 없이 실행하면 모든 SSOT 문서를 읽어 처음부터 `product-blueprint.html`을 생성한다.

```
/product-blueprint
```

### 부분 업데이트 모드

`--tab` 인자로 특정 탭만 갱신한다. 기존 `product-blueprint.html`이 반드시 존재해야 한다.

```
/product-blueprint --tab=기획
/product-blueprint --tab=디자인시스템
/product-blueprint --tab=화면디자인
/product-blueprint --tab=개발
/product-blueprint --tab=로드맵
```

**부분 업데이트 절차:**

1. 기존 `docs/ssot/product-blueprint.html`을 읽는다
2. 지정된 탭에 해당하는 SSOT 소스 문서를 읽는다:
   - `기획` → `docs/ssot/prd/*.md`
   - `디자인시스템` → `docs/ssot/design/system/tokens.css`
   - `화면디자인` → `docs/ssot/design/screens/screen-*.html` + `docs/ssot/prd/*.md` (화면 요구사항)
   - `개발` → `docs/ssot/dev/dev-plan.md`
   - `로드맵` → `docs/ssot/dev/deploy-roadmap.md`
3. 해당 탭의 콘텐츠 섹션만 최신 SSOT 문서 내용으로 교체한다
4. 나머지 탭의 콘텐츠는 그대로 유지한다
5. 커밋 메시지: `Docs: 제품 청사진 부분 업데이트 (탭: {탭이름})`

> **주의**: `product-blueprint.html`이 존재하지 않는 상태에서 `--tab` 인자를 사용하면 에러를 출력하고, 전체 생성 모드를 먼저 실행하도록 안내한다.

---

## 화면 디자인 탭 레이아웃

화면 디자인 탭에서는 각 화면을 **2컬럼 레이아웃**으로 표시한다:

| 왼쪽 컬럼 | 오른쪽 컬럼 |
|-----------|------------|
| 해당 화면의 디자인 HTML 미리보기 (iframe) | PRD에서 추출한 해당 화면의 요구사항 |

- 각 화면(`screen-*.html`)마다 2컬럼 행을 생성한다
- 화면 파일명과 PRD 내 화면 섹션을 매칭하여 해당 요구사항만 추출한다
- 모바일 뷰포트(390px 이하)에서는 1컬럼으로 스택한다 (미리보기 → 요구사항 순서)

---

## 갱신 정책

- SSOT 문서가 생성/수정될 때마다 이 스킬을 재실행하여 블루프린트를 최신 상태로 유지한다
- 단일 문서만 변경된 경우 부분 업데이트 모드(`--tab`)를 우선 사용한다
- 여러 문서가 동시에 변경되었거나 구조 변경이 있으면 전체 생성 모드를 사용한다
- 파이프라인의 어떤 단계에서든 실행 가능하다 (존재하는 문서만 반영)

---

## 모델 선택 가이드

- SSOT 문서 분석 + 콘텐츠 추출: `opus` (복합 문서 이해)
- HTML 생성 + 스타일링: `sonnet` (구조화된 코드 생성)

---

## 품질 체크리스트

- [ ] 존재하는 모든 SSOT 문서의 내용이 빠짐없이 반영되었는가?
- [ ] 탭 전환이 정상 작동하는가?
- [ ] 390px 뷰포트에서 레이아웃이 깨지지 않는가?
- [ ] 로드맵 진행률이 실제 체크 상태와 일치하는가?
- [ ] 화면 프리뷰가 정상 렌더링되는가?
- [ ] 플레이스홀더 텍스트 없이 모두 실제 한국어 콘텐츠인가?
- [ ] URL 해시 기반 탭 네비게이션이 작동하는가?

---

## 관련 스킬

- `app-plan` — 기획서 작성 (선행)
- `design-system-to-figma` — 디자인 토큰 + 디자인 시스템 생성 (선행)
- `prd-to-figma` — 화면별 디자인 HTML 생성 (선행)
- `dev-plan` — 개발 계획서 생성 (선행)
- `dev-roadmap` — 배포 로드맵 생성 (선행)
