# AI First 기술 스택 가이드

> Step 3에서 기술 스택을 결정할 때 참조한다.

## 핵심 사고방식

"내가 잘 아는 스택"이 아니라 **"AI(클로드 코드)가 가장 빠르고 정확하게 코딩할 수 있는 스택"**을 선택한다.

## AI First 스택 선택 기준

- AI 학습 데이터에 **예시가 풍부한** 기술 (커뮤니티 크고 문서 많은 것)
- **보일러플레이트가 적은** 기술 (설정 코드 < 비즈니스 로직)
- **단일 언어로 풀스택** 가능한 기술 (컨텍스트 스위칭 최소화)
- AI가 **한 번에 동작하는 코드**를 생성하기 쉬운 기술

## 앱 유형별 판단 플로우

```
Q1. 네이티브 기능(카메라, GPS, 센서 등)이 핵심인가?
    → YES: 안드로이드 네이티브 (Kotlin + Compose)
    → NO: Q2로

Q2. 빠른 검증이 최우선인가?
    → YES: 웹앱/PWA (Next.js or Flutter Web)
    → NO: Q3로

Q3. 구글플레이 배포가 필수인가?
    → YES + 웹도 필요: Flutter (단일 코드베이스)
    → YES + 앱만: KMP (Kotlin Multiplatform) or 네이티브
    → NO: 웹앱으로 충분
```

## AI 코딩 최적 스택 (2026년 기준)

### Tier 1: AI 코딩 최적 (추천)
- **Next.js + TypeScript + Tailwind + Supabase**
  - AI 학습 데이터 최다, 예시 풍부
  - 프론트+백+DB 단일 프로젝트
  - Vercel 원클릭 배포, PWA로 모바일 대응 가능
  - 적합: SaaS, 웹앱, 대시보드, 도구형 앱

- **Flutter + Dart + Firebase**
  - AI가 위젯 트리 생성 매우 잘함
  - 안드로이드+iOS+웹 동시 배포
  - 선언형 UI로 AI 코드 생성 정확도 높음
  - 적합: 모바일 우선 앱, 크로스 플랫폼

### Tier 2: AI 코딩 양호
- **Kotlin + Jetpack Compose + Firebase** — 안드로이드 전용, 네이티브 기능 필수
- **React Native + Expo + Supabase** — 빠른 프로토타입, JS 익숙할 때

### Tier 3: 특수 목적
- **Python + FastAPI + React**: AI/ML 모델 서빙 필요 시
- **Cursor + Vibe Coding**: 프로토타입 극한 속도

## 백엔드/인프라 (BaaS)

- **Supabase** (추천): PostgreSQL + Auth + Storage + Realtime (AI가 SQL 쿼리 생성 정확, 무료 티어 넉넉)
- **Firebase**: NoSQL + Auth + Hosting + Functions (실시간 기능 필요 시)
- **Convex / Appwrite**: 신규 대안

## AI API
- Claude API (Anthropic): 텍스트 분석/생성
- OpenAI API: 범용 AI 기능
- Google Gemini: 멀티모달

## 사용자에게 제안하는 형식

```
"이 앱은 [이유]로 [스택]이 AI 코딩에 가장 적합합니다.
- AI가 잘 생성하는 이유: ...
- MVP 속도 이점: ...
- 배포 편의성: ..."
```
