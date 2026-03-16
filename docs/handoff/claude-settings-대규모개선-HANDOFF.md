# claude-settings - 대규모 워크플로우 개선 Handoff

## Goal
one-tap-couple 프로젝트 경험을 기반으로 side-project-claude-settings의 스킬/규칙/문서를 전면 개선

## Current Phase
이슈 #7~#20 전부 반영 완료. 모든 이슈 닫힘. 구현 + README 정리까지 완료.

## What Was Done
- **신규 스킬 3개**: `/interview` (요구사항 인터뷰), `/product-blueprint` (SSOT 통합 마스터), `/sync-roadmap` (로드맵 최신화)
- **SSOT 디렉토리 구조 세분화**: `docs/ssot/` flat → `prd/`, `design/system/`, `design/screens/`, `dev/` 서브디렉토리. 모든 스킬 경로 업데이트
- **자율 실행 범위 극대화**: app-plan, dev-plan, dev-roadmap, resume에서 중간 확인 게이트 제거. 최종 결과 리뷰 1회로 통합
- **기획/디자인 단계 개선**: Figma export를 선택사항으로 변경, HTML 생성이 기본
- **개발 계획 단계 개선**: dev-plan에 플랫폼 스킬 자동 검색/설치 단계 추가
- **도식화 HTML/CSS 전환**: app-plan, dev-plan, dev-roadmap의 산출물 도식화를 HTML/CSS로 변경
- **product-blueprint 자동 업데이트**: init-project에서 빈 껍데기 생성, 각 파이프라인 스킬 완료 시 해당 탭 자동 업데이트
- **대화기록 정상화**: hook 스크립트의 JSON 필드명 수정 (.event → .hook_event_name, stdin에서 session_id 파싱)
- **refs/ 경로 표준화**: docs/refs/ 리서치 문서 경로 추가
- **README 전면 개편**: 다이어그램 3개 HTML/CSS로 제작 + 스크린샷 이미지 삽입, 중복 제거 (230줄 → 87줄)

## Key Decisions Made
- **settings.json 구조는 정상**: 스키마 확인 결과 이중 중첩 `hooks` 키가 올바른 구조. 로깅 문제는 스크립트의 JSON 필드명이 원인
- **CLAUDE.md 공통 rule 불필요**: one-tap-couple CLAUDE.md 분석 결과, 공통으로 뽑을 내용이 이미 workflow.md에 포함됨
- **다이어그램은 HTML 파일 + PNG 스크린샷 이중 관리**: GitHub README는 인라인 CSS 무시하므로, HTML로 제작 후 Chrome headless로 캡쳐하여 이미지 삽입
- **handoff/resume은 세션 관리 스킬로 분류**: 파이프라인 흐름이 아닌 중간중간 사용하는 스킬

## What Worked
- 병렬 서브에이전트로 스킬 파일 동시 수정 (11개 태스크 효율적 처리)
- Python PIL로 스크린샷 하단 빈 영역 자동 감지+crop

## What Didn't Work / Caveats
- Chrome headless에서 `backdrop-filter: blur()` 미지원 → 카드가 투명하게 렌더링됨. solid 배경으로 교체 필요
- Chrome headless에서 CSS 애니메이션 `opacity: 0` 초기값 → 스크린샷 시 요소 안 보임. 애니메이션 제거 필요
- `height: fit-content`가 Chrome headless에서 안 먹힘 → 큰 뷰포트로 캡쳐 후 Python crop이 가장 확실

## Key Files
- `rules/ssot.md` — SSOT 문서 구조 + 파이프라인 정의 (경로 전부 업데이트됨)
- `skills/product-blueprint/SKILL.md` — 마스터 문서 생성 스킬 (부분 업데이트 모드 포함)
- `skills/interview/SKILL.md` — 인터뷰 스킬 (6라운드, app-plan 연계)
- `skills/sync-roadmap/SKILL.md` — 로드맵 최신화 스킬
- `skills/init-project/SKILL.md` — 빈 product-blueprint.html 생성 + docs/refs/ 추가
- `docs/diagrams/` — 3개 HTML 다이어그램 + PNG 스크린샷
- `hooks/log-conversation.sh` — 수정된 로깅 스크립트
- `README.md` — 전면 개편

## Remaining Plan
1. 실제 새 프로젝트에서 `/init-project` → `/app-plan` → ... 파이프라인 E2E 테스트
2. product-blueprint.html 부분 업데이트 모드 실사용 검증
3. 플랫폼 스킬 검색/설치 로직 (dev-plan Step 3) 실사용 검증
4. 대화기록 로깅 훅 정상 동작 확인 (다음 세션에서 docs/sessions/ 파일 생성 여부)

## Notes for Next Session
- 사용자는 한국어 사용, 간결한 소통 선호
- 규칙 파일 변경 시 반드시 사용자 확인 (meta.md)
- 이 레포는 "설정 템플릿 레포"이므로 실제 앱 코드는 없음
- one-tap-couple (`~/one-tap-couple`) 프로젝트가 참고 프로젝트

## Quick Start Command
```
/resume
```
