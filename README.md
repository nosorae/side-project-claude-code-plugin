# Side Project Claude Settings

사이드 프로젝트에서 재사용하는 Claude Code 스킬 모음.

## 포함된 스킬

| 스킬 | 설명 |
|------|------|
| `ideation` | 6개 병렬 에이전트로 앱 아이디어 발굴 + 점수화 |
| `app-plan` | 4단계 앱 기획 (아이디어 검증 → 가치 정의 → MVP → 유저 플로우) |
| `figma-design-system` | PRD → 디자인 시스템 HTML → Figma 내보내기 |
| `prd-to-figma` | PRD 화면 정의 → 화면별 HTML → Figma 페이지 |
| `sync` | Git pull + 충돌 해결 + 변경 내역 표시 |

## 설치

프로젝트의 `.claude/skills/` 디렉토리에 복사:

```bash
# 전체 스킬 복사
cp -r ~/side-project-claude-settings/skills/* <프로젝트>/.claude/skills/

# 또는 특정 스킬만
cp -r ~/side-project-claude-settings/skills/ideation <프로젝트>/.claude/skills/
```

## 스킬 의존성

```
ideation → app-plan (아이디어 선택 후 기획)
figma-design-system → prd-to-figma (tokens.css 생성 선행 필요)
```

`figma-design-system`과 `prd-to-figma`는 `frontend-design:frontend-design` 스킬이 있으면 디자인 품질이 향상됩니다.
