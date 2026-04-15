# 파이프라인 순서 규칙

## 파이프라인 흐름

모든 파이프라인 스킬은 아래 순서를 따른다. 각 스킬은 실행 전에 선행 단계의 산출물이 존재하는지 반드시 확인해야 한다.

```
(선택) /market-research → /app-plan → /design-system-to-figma → /prd-to-figma
                                   → /dev-plan → /dev-roadmap → /create-issues
```

## 산출물 기반 전제조건 매핑

| 스킬 | 선행 산출물 (하나라도 없으면 경고) | 산출물 |
|------|----------------------------------|--------|
| market-research | (없음) | `docs/ssot/prd/*-시장조사.md` |
| app-plan | (없음, market-research는 선택) | `docs/ssot/prd/*-기획서.md` |
| design-system-to-figma | `docs/ssot/prd/*-기획서.md` | `docs/ssot/design/system/tokens.css` |
| prd-to-figma | `docs/ssot/design/system/tokens.css` | `docs/ssot/design/screens/screen-*.html` |
| dev-plan | `docs/ssot/prd/*-기획서.md` | `docs/ssot/dev/dev-plan.md` |
| dev-roadmap | `docs/ssot/dev/dev-plan.md` | `docs/ssot/dev/deploy-roadmap.md` |
| create-issues | `docs/ssot/dev/deploy-roadmap.md` | GitHub Issues |

## 전제조건 미충족 시 행동 (필수)

파이프라인 스킬의 선행 산출물이 없으면 **반드시** 아래 순서로 행동한다:

1. **안내**: 어떤 선행 스킬이 필요한지 알려준다
   ```
   ⚠️ 이 스킬을 실행하려면 먼저 `/app-plan`으로 기획서를 작성해야 합니다.
   현재 docs/ssot/prd/ 에 기획서 파일이 없습니다.
   ```
2. **선택지 제시**:
   ```
   선택하세요:
   a) /app-plan 먼저 실행 (권장)
   b) --skip으로 전제조건 건너뛰고 진행 (비권장 — 산출물 품질 저하 가능)
   ```
3. **스킵 시 경고 기록**: `--skip` 선택 시 산출물 파일 상단에 경고를 남긴다
   ```markdown
   > ⚠️ 이 문서는 선행 단계(기획서)를 건너뛰고 생성되었습니다. 품질 검토 필요.
   ```

## 파이프라인 현황 조회

사용자가 "현황", "어디까지 했지", "파이프라인 상태" 등을 물으면:
- 위 산출물 매핑 테이블을 기준으로 각 파일 존재 여부를 체크한다
- 완료/미완료를 시각적으로 표시한다:
  ```
  ✅ 기획서 (docs/ssot/prd/2026-04-15-MyApp-기획서.md)
  ✅ 디자인 토큰 (docs/ssot/design/system/tokens.css)
  ⬜ 화면 디자인 — 다음 단계: /prd-to-figma
  ⬜ 개발 계획
  ⬜ 배포 로드맵
  ⬜ GitHub Issues
  ```

## 기술 스택 스킬 설치 (dev-plan 완료 시 필수)

dev-plan에서 기술 스택이 결정되면 **반드시** 해당 스택의 베스트 프랙티스 스킬을 검색하고 설치한다.
사용자에게 "설치하지 않겠습니다"라는 선택지는 제공하지 않는다 — 어떤 스킬을 설치할지만 확인한다.

자세한 내용은 dev-plan 스킬의 "기술 스택 스킬 설치" 섹션을 참조한다.
