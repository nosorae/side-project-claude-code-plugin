---
name: prd-to-figma
description: "Use when the user wants to convert PRD screen definitions into Figma designs using a tokens.css-based HTML pipeline. Triggered by requests like 'PRD 화면을 Figma로 만들어줘', 'PRD에서 Figma 화면 생성', '/prd-to-figma'."
---

# PRD to Figma

## 목적

PRD 마크다운의 화면 정의를 파싱하여, 디자인 토큰(tokens.css) 기반 HTML을 화면별로 생성하고, Figma MCP `generate_figma_design`으로 Figma 파일에 화면별 페이지로 내보낸다.

## 사용법

```bash
# 기본: PRD 경로 + Figma URL
/prd-to-figma docs/plans/my-app-spec.md https://www.figma.com/design/ABC123/MyApp

# 특정 화면만 필터링
/prd-to-figma docs/plans/my-app-spec.md https://www.figma.com/design/ABC123/MyApp --screen 로그인,홈

# Figma URL 없이 (실행 중 질문)
/prd-to-figma docs/plans/my-app-spec.md
```

- 첫 번째 인자: PRD 파일 경로 (필수)
- 두 번째 인자: Figma URL (선택, 없으면 실행 중 사용자에게 질문)
- `--screen`: 특정 화면만 필터링 (선택, 쉼표 구분)

## 전제 조건

- `/design-system-to-figma`이 먼저 실행되어 `docs/ssot/tokens.css`가 존재해야 한다
- tokens.css가 없으면 즉시 중단하고 아래 메시지를 출력한다:

> tokens.css가 없습니다. `/design-system-to-figma`을 먼저 실행해주세요.

---

## 실행 워크플로우

### Step 1: 전제 조건 확인

1. `Read` 도구로 `docs/ssot/tokens.css` 존재 확인
2. 파일이 없으면 즉시 중단, 사용자에게 `/design-system-to-figma` 선행 실행 안내
3. 파일이 있으면 내용을 읽어 디자인 토큰 값을 파악한다

### Step 2: PRD 파싱

1. `Read` 도구로 PRD 마크다운 파일을 읽는다
2. 화면 단위로 분리한다. 인식 패턴:
   - `## 화면: {이름}`
   - `## Screen: {이름}`
   - `### {이름}` (하위 제목이 화면 정의인 경우)
3. 각 화면에서 추출할 정보:
   - 구성요소 (버튼, 입력 필드, 카드, 목록 등)
   - 동작 (클릭, 네비게이션, 상태 전환)
   - 상태 (기본, 로딩, 에러, 빈 화면)
4. `--screen` 필터가 있으면 해당 화면만 선택한다

### Step 2.5: 디자인 스킬 로드

HTML 생성 전에 반드시 `frontend-design` 스킬을 호출하여 디자인 원칙과 스타일 가이드를 로드한다:

```
Skill("frontend-design:frontend-design")
```

이 스킬이 제공하는 디자인 원칙(여백, 타이포그래피, 색상, 인터랙션 등)을 Step 3의 HTML 생성에 적용한다.

### Step 3: 화면별 HTML 생성

각 화면마다 독립된 HTML 파일을 생성한다.

**HTML 프레임 규격:**
- 390x844 모바일 프레임 (iPhone 14 기준)

**HTML 구성 규칙:**
- `docs/ssot/tokens.css` 전체 내용을 `<style>` 태그로 HTML `<head>`에 주입
- Tailwind CDN (`<script src="https://cdn.tailwindcss.com"></script>`) + CSS 변수 스타일링
- 모든 텍스트는 실제 한국어 사용 (Lorem ipsum 절대 금지)
- 배경: `var(--color-bg)` 또는 `#F8F9FA`

**파일 저장:**
- 화면당 1개 HTML 파일
- 경로: `docs/ssot/screen-{번호}-{이름}.html`
- `Write` 도구로 저장
- 예: `screen-01-로그인.html`, `screen-02-홈.html`, `screen-03-상세.html`

### Step 4: 순차 캡처 → Figma

화면마다 아래 과정을 반복한다:

#### 4-1. 로컬 서버 시작

```bash
# Bash 도구로 백그라운드 실행 (run_in_background: true)
cd docs/ssot && python3 -m http.server 8765
```

- 서버 URL: `http://localhost:8765/screen-{번호}-{이름}.html`

#### 4-2. Figma URL에서 fileKey 추출

**URL 파싱 규칙:**

| URL 패턴 | 추출 대상 |
|----------|-----------|
| `figma.com/design/:fileKey/:fileName` | fileKey |
| `figma.com/design/:fileKey/branch/:branchKey/:fileName` | branchKey |
| `figma.com/file/:fileKey/:fileName` | fileKey |

예시:
- `https://www.figma.com/design/ABC123/MyApp` → fileKey = `ABC123`
- `https://www.figma.com/design/ABC123/branch/DEF456/MyApp` → fileKey = `DEF456` (branch)

**Figma URL이 없는 경우:**

사용자에게 질문한다:
```
화면을 내보낼 Figma 파일 URL을 알려주세요.
(예: https://www.figma.com/design/ABC123/MyApp)
```

#### 4-3. Figma MCP로 내보내기

**Phase A: 캡처 시작**

ToolSearch로 `mcp__figma__generate_figma_design`을 로드한 뒤, 파라미터 없이 호출:

```
mcp__figma__generate_figma_design()
```

- 도구가 캡처 안내 지침을 반환한다
- 지침에 따라 `http://localhost:8765/screen-{번호}-{이름}.html` 페이지를 캡처한다
- captureId를 획득한다

**Phase B: 폴링**

captureId로 5초 간격 폴링 (최대 10회):

```
mcp__figma__generate_figma_design(
  captureId: "{captureId}"
)
```

- 상태가 완료될 때까지 반복
- 10회 초과 시 해당 화면을 실패로 기록하고 다음 화면으로 진행

**Phase C: 파일에 삽입**

캡처가 완료되면 기존 Figma 파일에 삽입:

```
mcp__figma__generate_figma_design(
  captureId: "{captureId}",
  outputMode: "existingFile",
  fileKey: "{fileKey}"
)
```

#### 4-4. 로컬 서버 종료

```bash
lsof -ti:8765 | xargs kill -9 2>/dev/null || true
```

#### 4-5. 다음 화면으로 반복

모든 화면에 대해 4-1 ~ 4-4를 순차적으로 반복한다.

**Figma 파일 내 최종 구조:**

```
MyApp (Figma File)
├── Design System    ← /design-system-to-figma이 생성
├── 로그인            ← 화면별 페이지
├── 홈
├── 상세
└── ...
```

### Step 5: 완료 보고

최종 응답에 반드시 포함:

1. **생성된 화면 목록**: 성공/실패 상태 구분
2. **Figma 파일 링크**: `https://www.figma.com/design/{fileKey}`
3. **실패 화면의 에러 사유** (있을 경우)
4. **생성된 HTML 파일 경로 목록**

---

## PRD 화면 정의 권장 형식

PRD에서 화면을 정의할 때 아래 형식을 따르면 파싱 정확도가 높아진다:

```markdown
## 화면: 로그인
- 상단 앱 로고
- 이메일 입력 필드 (placeholder: "이메일 주소")
- 비밀번호 입력 필드 (placeholder: "비밀번호")
- 로그인 버튼 (Primary, Full-width)
- "비밀번호 찾기" 텍스트 링크
- 구분선 "또는"
- 소셜 로그인 버튼들 (Google, Apple, Kakao)

## 화면: 홈
- 상단 바 (프로필 아이콘 + 앱 타이틀 + 알림 아이콘)
- 검색 바
- 추천 카드 섹션 (가로 스크롤)
- 최근 항목 리스트
- 하단 탭 바 (홈, 탐색, 마이페이지)
```

---

## HTML 생성 규칙

### 디자인 원칙

`frontend-design:frontend-design` 스킬에서 제공하는 디자인 원칙을 따른다. Step 2.5에서 로드한 스킬의 가이드라인(여백, 타이포그래피 위계, 색상 사용, 터치 타겟, 곡선, 그리드 등)을 적용한다.

### 컴포넌트 매핑

PRD 텍스트에서 UI 컴포넌트로 변환하는 규칙:

| PRD 표현 | HTML 구현 | 스타일 |
|----------|-----------|--------|
| "버튼", "CTA" | `<button>` | `var(--color-primary)` 배경, 흰색 텍스트, h=52px, radius=12px |
| "입력 필드", "텍스트 입력" | `<input>` | `#F2F4F6` 배경, h=48px, radius=8px |
| "카드" | `<div>` | 흰색 배경, radius=16px, `box-shadow: 0 2px 8px rgba(0,0,0,0.04)` |
| "탭 바", "하단 네비" | `<nav>` | 하단 고정, h=72px (SafeArea 포함), 아이콘+라벨 |
| "상단 바", "헤더" | `<header>` | 상단 고정, h=56px, 뒤로가기+제목+액션 |
| "리스트", "목록" | `<ul>/<li>` | 구분선, padding 16px, 화살표 아이콘 |
| "이미지", "썸네일" | `<div>` | 회색 placeholder 배경, aspect-ratio 유지 |
| "구분선" | `<hr>` 또는 `<div>` | 1px `#F2F4F6`, margin 상하 16px |
| "텍스트 링크" | `<a>` | `var(--color-primary)`, underline 없음 |

### 컴포넌트 상세 규격

**Button:**
- Primary: `var(--color-primary)` 배경 + 흰색 텍스트, height 52px, radius 12px, font-weight 600
- Secondary: 흰색 배경 + `var(--color-primary)` 테두리/텍스트, height 48px
- 전체 너비(width: 100%) 기본

**Input:**
- height 48px, radius 8px
- Default: `#F2F4F6` 배경, placeholder `#8B95A1`
- Focused: `var(--color-primary)` 테두리 2px
- Error: `var(--color-error)` 테두리 + 하단 오류 메시지

**Card:**
- 흰색 배경 + radius 16px + `box-shadow: 0 2px 8px rgba(0,0,0,0.04)`
- padding 16~20px

**TopBar:**
- height 56px, 뒤로가기 아이콘(좌) + 제목(중앙) + 액션(우)
- 제목: 18px semibold

**BottomNav:**
- height 72px (SafeArea 포함)
- 4~5개 탭, 아이콘(24px) + 라벨(11px)
- 활성 탭: `var(--color-primary)`, 비활성: `#8B95A1`

---

## Troubleshooting

### tokens.css 없음

- **원인**: `/design-system-to-figma`이 선행 실행되지 않았다
- **해결**: `/design-system-to-figma {PRD경로} {FigmaURL}`을 먼저 실행한다
- `docs/ssot/tokens.css`가 생성된 후 `/prd-to-figma`를 다시 실행한다

### 화면 파싱 실패

- **원인**: PRD 마크다운에 화면 구분 패턴이 없다
- **해결**: 사용자에게 PRD 권장 형식을 안내한다
  - `## 화면: {이름}` 또는 `## Screen: {이름}` 패턴 사용 권장
  - 각 화면 아래 구성요소를 불릿 리스트로 나열

### generate_figma_design 타임아웃

- **원인**: 네트워크 지연 또는 Figma 서버 과부하
- **해결**: 해당 화면을 실패로 기록하고 다음 화면으로 진행
- 완료 보고에서 실패한 화면과 에러 사유를 명시한다
- 사용자가 원하면 실패 화면만 재시도 가능

### 로컬 서버 포트 충돌

- 8765 포트가 이미 사용 중일 때 발생
- 해결: 다른 포트로 순차 시도 (8766, 8767)
  ```bash
  python3 -m http.server 8766
  ```
- URL도 변경된 포트에 맞게 수정

### Figma MCP 연결 안 됨

- `ToolSearch`로 `mcp__figma__generate_figma_design` 로드 확인
- 도구가 없으면 `/mcp` 명령으로 MCP 서버 재연결 안내
- Figma 앱이 실행 중이고 MCP 플러그인이 활성화되어 있는지 확인

### Figma URL 파싱 실패

- URL 형식이 예상과 다를 경우 사용자에게 fileKey를 직접 질문
- `figma.com/design/` 또는 `figma.com/file/` 패턴만 지원

---

## 금지 규칙

- Lorem ipsum / placeholder 텍스트 금지 - 실제 한국어 텍스트 사용
- description 프론트매터에 워크플로우 요약 금지
- tokens.css 없이 실행 금지 - 반드시 전제 조건 확인 후 진행
- 스펙에 없는 화면을 임의 추가하지 않는다
- 시각적 장식만 늘리고 정보 구조를 흐리게 만들지 않는다
- 외부 이미지/폰트 파일 직접 참조 금지 (CDN만 허용)
