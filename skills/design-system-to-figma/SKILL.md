---
name: design-system-to-figma
description: |
  PRD나 스펙 문서를 기반으로 모바일 디자인 시스템을 생성하는 스킬. 디자인 토큰(tokens.css)과 컴포넌트 시스템 HTML을 만든다.
  이 스킬은 다음과 같은 요청에 반드시 사용한다: "디자인 시스템 만들어줘", "디자인 토큰 생성", "컴포넌트 시스템", "PRD로 디자인", "/design-system-to-figma", "tokens.css 만들어줘".
  기획서가 완성된 후 디자인 단계에 진입하는 맥락이면 이 스킬을 사용한다. HTML 생성이 기본이며, Figma 내보내기는 사용자 요청 시에만 수행.
user_invocable: true
---

# Figma Design System

## 목적

PRD/스펙 마크다운 파일을 분석하여 디자인 시스템 HTML을 생성한다. HTML 파일을 로컬 브라우저에서 확인하는 것이 기본 워크플로우이며, Figma 내보내기는 사용자가 명시적으로 요청한 경우에만 수행한다.

## 사용법

```bash
# 기본: PRD 경로 (HTML 생성만)
/design-system-to-figma docs/plans/my-app-spec.md

# Figma export도 함께 수행할 경우: PRD 경로 + Figma URL
/design-system-to-figma docs/plans/my-app-spec.md https://www.figma.com/design/ABC123/MyApp
```

- 첫 번째 인자: PRD 파일 경로 (필수)
- 두 번째 인자: Figma URL (선택, 있으면 Figma 내보내기도 수행)

---

## 실행 워크플로우

### Step 0: 파이프라인 전제조건 확인

1. `docs/ssot/prd/` 디렉토리에서 `*-기획서.md` 파일을 검색한다
2. **기획서가 없으면**:
   ```
   ⚠️ 이 스킬을 실행하려면 먼저 `/app-plan`으로 기획서를 작성해야 합니다.
   현재 docs/ssot/prd/ 에 기획서 파일이 없습니다.

   선택하세요:
   a) /app-plan 먼저 실행 (권장)
   b) --skip으로 전제조건 건너뛰고 진행 (비권장)
   ```
3. `--skip` 선택 시 → 사용자에게 PRD 파일 경로를 직접 물어보고 진행. 산출물에 스킵 경고 표시.

### Step 1: PRD 분석

1. `Read` 도구로 PRD 마크다운 파일을 읽는다
2. 앱 성격을 파악하여 primary color 방향을 결정한다:
   - 금융/핀테크 → 블루 계열 (`#3182F6`)
   - 배달/음식 → 오렌지 계열 (`#FF6B00`)
   - 헬스/운동 → 그린 계열 (`#34C759`)
   - 소셜/커뮤니티 → 퍼플 계열 (`#7C3AED`)
   - 커머스/쇼핑 → 레드 계열 (`#FF3B30`)
   - 생산성/도구 → 인디고 계열 (`#4F46E5`)
   - 교육/학습 → 틸 계열 (`#0D9488`)
   - 기본값 → 블루 (`#3182F6`)
3. 필요한 컴포넌트 유형을 식별한다 (Button, Input, Card, List, Tab, Navigation 등)

### Step 2: 디자인 토큰 생성

아래 내장 토큰을 베이스로, Step 1에서 결정한 primary color로 커스터마이징한다.

**내장 토큰 기본값:**

```css
:root {
  --color-primary: #3182F6;
  --color-secondary: #F2F4F6;
  --color-success: #34C759;
  --color-error: #FF3B30;
  --color-text-primary: #191F28;
  --color-text-secondary: #8B95A1;
  --color-bg: #FFFFFF;
  --font-family: -apple-system, 'Pretendard', sans-serif;
  --text-hero: 26px/1.3;
  --text-heading: 20px/1.4;
  --text-body: 16px/1.5;
  --text-caption: 13px/1.4;
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-full: 9999px;
}
```

- PRD 힌트에 따라 `--color-primary`를 앱 성격에 맞게 변경
- `Write` 도구로 `docs/ssot/design/system/tokens.css`에 저장

### Step 2.5: 디자인 스킬 로드 (필수 — 없으면 설치)

HTML 생성 전에 반드시 `frontend-design` 스킬이 필요하다. 다음 순서로 확인한다:

1. **설치 확인**: `Skill("frontend-design:frontend-design")` 호출을 시도한다
2. **미설치 시 자동 설치**: 스킬이 없으면 즉시 설치한다:
   ```bash
   claude plugin add anthropic/frontend-design
   ```
   설치 후 다시 `Skill("frontend-design:frontend-design")`을 호출한다.
3. **설치 실패 시**: 사용자에게 알리고 수동 설치를 안내한다:
   ```
   frontend-design 스킬을 자동 설치할 수 없습니다.
   수동으로 설치해주세요: claude plugin add anthropic/frontend-design
   설치 후 이 스킬을 다시 실행해주세요.
   ```
   **이 스킬의 실행을 중단한다** — frontend-design 없이 HTML을 생성하면 안 된다.

이 스킬이 제공하는 디자인 원칙(여백, 타이포그래피, 색상, 인터랙션 등)을 Step 3의 HTML 생성에 적용한다.

### Step 3: 디자인 시스템 HTML 생성

390x844 모바일 프레임(iPhone 14) 기준으로 디자인 시스템 HTML을 생성한다.

**HTML 구성 규칙:**

- Tailwind CDN (`<script src="https://cdn.tailwindcss.com"></script>`) + CSS 변수 스타일링
- 모든 텍스트는 실제 한국어 사용 (Lorem ipsum 절대 금지)
- 배경: `#F8F9FA` (시스템 전체 배경)

**페이지 섹션 구성:**

1. **Color Palette** - Primary, Secondary, Success, Error, Text Primary, Text Secondary, Background
2. **Typography Scale** - Hero(26px), Heading(20px), Body(16px), Caption(13px) 각각 예시 텍스트
3. **Component Library**:
   - Button: Primary(filled), Secondary(outlined), Disabled 상태
   - Input: Default, Focused, Error, Disabled 상태
   - Card: 기본 카드, 리스트 아이템 카드
   - List: 단일 행, 아이콘+텍스트 행, 화살표 포함 행
   - Tab: 활성/비활성 탭 바
   - Navigation: TopBar(뒤로가기+제목+액션), BottomNav(4~5탭)
4. **Spacing & Radius** - xs/sm/md/lg/xl 간격 시각화, sm/md/lg/full 라운딩 시각화

**HTML 파일 저장:**

- `Write` 도구로 `docs/ssot/design/system/design-system.html`에 저장
- 파일은 단일 HTML (외부 리소스는 CDN만 허용)

### Step 4: 로컬 브라우저 확인 (기본)

HTML 파일을 로컬 서버로 띄워 브라우저에서 바로 확인한다.

```bash
# Bash 도구로 백그라운드 실행 (run_in_background: true)
cd docs/ssot/design/system && python3 -m http.server 8765
```

사용자에게 안내:
```
디자인 시스템 HTML이 생성되었습니다.
브라우저에서 확인하세요: http://localhost:8765/design-system.html

HTML 파일을 직접 수정하고 브라우저를 새로고침하면 바로 반영됩니다.
수정이 필요하면 말씀해주세요.
```

### Step 4-F: Figma 내보내기 (선택 - 사용자가 요청한 경우에만)

> **이 단계는 사용자가 Figma export를 명시적으로 요청한 경우에만 실행한다.** 기본 워크플로우는 Step 4에서 종료된다.

#### 4-F-1. Figma URL에서 fileKey 추출

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
디자인 시스템을 내보낼 Figma 파일 URL을 알려주세요.
(예: https://www.figma.com/design/ABC123/MyApp)
```

#### 4-F-2. Figma MCP로 내보내기

**Phase A: 캡처 시작**

ToolSearch로 `mcp__figma__generate_figma_design`을 로드한 뒤, 파라미터 없이 호출:

```
mcp__figma__generate_figma_design()
```

- 도구가 캡처 안내 지침을 반환한다
- 지침에 따라 `http://localhost:8765/design-system.html` 페이지를 캡처한다
- captureId를 획득한다

**Phase B: 폴링**

captureId로 5초 간격 폴링 (최대 10회):

```
mcp__figma__generate_figma_design(
  captureId: "{captureId}"
)
```

- 상태가 완료될 때까지 반복
- 10회 초과 시 사용자에게 타임아웃 알림

**Phase C: 파일에 삽입**

캡처가 완료되면 기존 Figma 파일에 삽입:

```
mcp__figma__generate_figma_design(
  captureId: "{captureId}",
  outputMode: "existingFile",
  fileKey: "{fileKey}"
)
```

#### 4-F-3. 로컬 서버 종료

```bash
# 포트 8765 사용 중인 프로세스 종료
lsof -ti:8765 | xargs kill -9 2>/dev/null || true
```

### Step 4.5: product-blueprint 자동 업데이트

product-blueprint.html의 디자인 시스템 탭을 자동 업데이트한다. `/product-blueprint --tab=디자인시스템` 실행.

### Step 5: 완료 보고

최종 응답에 반드시 포함:

1. **생성된 파일 목록**:
   - tokens.css 경로: `docs/ssot/design/system/tokens.css`
   - design-system.html 경로: `docs/ssot/design/system/design-system.html`
2. **로컬 확인 URL**: `http://localhost:8765/design-system.html`
3. **생성된 컴포넌트 요약**: Color, Typography, Button, Input, Card 등
4. **다음 단계 안내**: `/prd-to-figma`로 실제 화면 생성 진행
5. **Figma 내보내기 안내**: "Figma로 내보내려면 `/design-system-to-figma` 실행 시 Figma URL을 함께 전달하거나, 'Figma로 내보내줘'라고 요청하세요."
6. **(Figma export 수행한 경우)** Figma 파일 링크: `https://www.figma.com/design/{fileKey}`

---

## 디자인 원칙

`frontend-design:frontend-design` 스킬에서 제공하는 디자인 원칙을 따른다. Step 2.5에서 로드한 스킬의 가이드라인(여백, 타이포그래피 위계, 색상 사용, 곡선, 그리드 등)을 적용한다.

### 컴포넌트 상세 규칙

**Button:**
- Primary: `--color-primary` 배경 + 흰색 텍스트, height 52px, radius 12px
- Secondary: 흰색 배경 + `--color-primary` 테두리/텍스트, height 48px
- 전체 너비(width: 100%) 기본

**Input:**
- height 48px, radius 8px
- Default: `#F2F4F6` 배경, placeholder `#8B95A1`
- Focused: `--color-primary` 테두리 2px
- Error: `--color-error` 테두리 + 하단 오류 메시지

**Card:**
- 흰색 배경 + radius 16px + `box-shadow: 0 2px 8px rgba(0,0,0,0.04)`
- padding 16~20px

**TopBar:**
- height 56px, 뒤로가기 아이콘(좌) + 제목(중앙) + 액션(우)
- 제목: 18px semibold

**BottomNav:**
- height 72px (SafeArea 포함)
- 4~5개 탭, 아이콘(24px) + 라벨(11px)
- 활성 탭: `--color-primary`, 비활성: `#8B95A1`

---

## Troubleshooting

### `generate_figma_design` 타임아웃

- 폴링 10회(50초) 초과 시 사용자에게 알림
- 원인: 네트워크 지연 또는 Figma 서버 과부하
- 해결: 잠시 후 captureId로 재시도하거나, HTML 파일을 수동으로 Figma에 임포트

### 로컬 서버 포트 충돌

- 8765 포트가 이미 사용 중일 때 발생
- 해결: 다른 포트로 변경 (8766, 8767 순차 시도)
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
- 스펙에 없는 컴포넌트를 임의 추가하지 않는다
- 시각적 장식만 늘리고 정보 구조를 흐리게 만들지 않는다
- 외부 이미지/폰트 파일 직접 참조 금지 (CDN만 허용)
