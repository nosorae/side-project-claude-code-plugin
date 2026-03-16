# 프로젝트 문서 구조 (SSOT)

프로젝트의 핵심 문서는 아래 경로에 저장된다. 작업 중 관련 문서가 필요하면 이 경로에서 참조한다.

| 문서 종류 | 경로 | 생성 주체 |
|-----------|------|---------|
| 기획서 (PRD) | `docs/ssot/prd/YYYY-MM-DD-{앱이름}-기획서.md` | `/app-plan` 스킬 |
| 디자인 토큰 | `docs/ssot/design/system/tokens.css` | `/design-system-to-figma` 스킬 |
| 디자인 시스템 HTML | `docs/ssot/design/system/design-system.html` | `/design-system-to-figma` 스킬 |
| 화면별 디자인 HTML | `docs/ssot/design/screens/screen-*.html` | `/prd-to-figma` 스킬 |
| 개발 계획서 | `docs/ssot/dev/dev-plan.md` | `/dev-plan` 스킬 |
| 배포 로드맵 | `docs/ssot/dev/deploy-roadmap.md` | `/dev-roadmap` 스킬 |
| 제품 청사진 (마스터) | `docs/ssot/product-blueprint.html` | `/product-blueprint` 스킬 |
| 인터뷰 노트 | `docs/ssot/prd/interview-notes.md` | `/interview` 스킬 |
| 유저 플로우 | `docs/ssot/prd/userflow.html` | `/app-plan` 스킬 |
| 화면 전환 맵 | `docs/ssot/prd/screen-map.html` | `/app-plan` 스킬 |
| 아키텍처 다이어그램 | `docs/ssot/dev/architecture.html` | `/dev-plan` 스킬 |
| 로드맵 시각화 | `docs/ssot/dev/roadmap-visual.html` | `/dev-roadmap` 스킬 |
| 리서치/참고자료 | `docs/refs/{주제}.md` | 조사 필요 스킬 (app-plan, dev-plan 등) |
| 핸드오프 | `docs/handoff/{세션이름}-HANDOFF.md` | `/handoff` 스킬 |
| 대화 기록 | `docs/sessions/{YYYY-MM-DD}-{session_id}.md` | 자동 로깅 훅 |
| 작업 관리 | GitHub Issues (에픽/하위) | `/create-issues` 스킬 |
| 교훈 기록 | `docs/lessons/{제목}.md` | 자기개선 루프 |

## 스킬 파이프라인

```
interview → app-plan → design-system-to-figma → prd-to-figma → dev-plan → dev-roadmap → create-issues
(인터뷰)   (기획서)    (토큰+디자인시스템)      (화면별 디자인) (개발 계획)  (배포 로드맵)  (이슈 생성)
                                                                    ↓
                                              product-blueprint (SSOT 통합 마스터 문서, 언제든 실행 가능)
```

- `/interview`는 선택사항이다. 아이디어가 충분히 구체적이면 바로 `/app-plan`으로 시작 가능하다.
- `/product-blueprint`는 파이프라인 어느 시점에서든 실행 가능하다. SSOT 문서가 추가/변경될 때마다 재실행 권장.
- `/sync-roadmap`은 구현 단계에서 수시로 실행하여 로드맵 문서를 최신화한다.

- `design-system-to-figma`은 `docs/ssot/design/system/tokens.css`를 생성한다. `prd-to-figma`는 이 파일이 없으면 실행을 거부한다.
- `design-system-to-figma`과 `prd-to-figma`는 `frontend-design:frontend-design` 스킬이 있으면 디자인 품질이 향상된다.
- `dev-plan`은 기획서(`docs/ssot/prd/` 내 PRD)가 존재해야 실행 가능하다.
- `dev-roadmap`은 `docs/ssot/dev/dev-plan.md`가 존재해야 실행 가능하다.
- `create-issues`는 `docs/ssot/dev/deploy-roadmap.md`가 존재하고 GitHub 레포가 연결되어야 실행 가능하다.

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
