# 프로젝트 문서 구조 (SSOT)

프로젝트의 핵심 문서는 아래 경로에 저장된다. 작업 중 관련 문서가 필요하면 이 경로에서 참조한다.

| 문서 종류 | 경로 | 생성 주체 |
|-----------|------|---------|
| 기획서 (PRD) | `docs/ssot/YYYY-MM-DD-{앱이름}-기획서.md` | `/app-plan` 스킬 |
| 디자인 토큰 | `docs/ssot/tokens.css` | `/design-system-to-figma` 스킬 |
| 디자인 시스템 HTML | `docs/ssot/design-system.html` | `/design-system-to-figma` 스킬 |
| 화면별 디자인 HTML | `docs/ssot/screen-*.html` | `/prd-to-figma` 스킬 |
| 개발 계획서 | `docs/ssot/dev-plan.md` | `/dev-plan` 스킬 |
| 배포 로드맵 | `docs/ssot/deploy-roadmap.md` | `/dev-roadmap` 스킬 |
| 핸드오프 | `docs/handoff/{세션이름}-HANDOFF.md` | `/handoff` 스킬 |
| 대화 기록 | `docs/sessions/{YYYY-MM-DD}-{session_id}.md` | 자동 로깅 훅 |
| 작업 관리 | GitHub Issues (에픽/하위) | `/create-issues` 스킬 |
| 교훈 기록 | `docs/lessons/{제목}.md` | 자기개선 루프 |

## 스킬 파이프라인

```
app-plan → design-system-to-figma → prd-to-figma → dev-plan → dev-roadmap → create-issues
(기획서)    (토큰+디자인시스템)    (화면별 디자인) (개발 계획)  (배포 로드맵)  (이슈 생성)
```

- `design-system-to-figma`은 `docs/ssot/tokens.css`를 생성한다. `prd-to-figma`는 이 파일이 없으면 실행을 거부한다.
- `design-system-to-figma`과 `prd-to-figma`는 `frontend-design:frontend-design` 스킬이 있으면 디자인 품질이 향상된다.
- `dev-plan`은 기획서(`docs/ssot/` 내 PRD)가 존재해야 실행 가능하다.
- `dev-roadmap`은 `docs/ssot/dev-plan.md`가 존재해야 실행 가능하다.
- `create-issues`는 `docs/ssot/deploy-roadmap.md`가 존재하고 GitHub 레포가 연결되어야 실행 가능하다.

## SSOT 경계

- 다른 프로젝트의 문서를 참조하거나 가져오지 않는다
- 현재 프로젝트의 문서를 다른 프로젝트 경로에 생성하지 않는다
- 모든 프로젝트 문서는 해당 프로젝트 루트 아래에만 존재한다

## SSOT 일관성 유지

- 사용자가 기획, 디자인, 개발, 로드맵 중 하나를 변경하거나 추가 요청하면:
  1. `docs/ssot/` 내 관련 문서를 모두 확인한다
  2. 변경 내용과 상이한 부분이 있는 문서를 찾아 함께 수정한다
  3. 예: 기획서에서 화면이 추가되면 → dev-plan, deploy-roadmap도 반영 필요 여부 확인
- SSOT 문서 간 불일치가 발견되면 사용자에게 알리고 수정한다
