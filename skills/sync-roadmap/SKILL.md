---
description: Issue/PR 기준으로 로드맵 문서를 최신화하는 스킬. GitHub Issues 상태를 조회하여 deploy-roadmap.md에 진행 상황을 반영
user_invocable: true
---

# Sync Roadmap (로드맵 최신화)

GitHub Issues 상태를 조회하여 배포 로드맵(`docs/ssot/dev/deploy-roadmap.md`)의 진행 상황을 최신화하는 스킬입니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "로드맵 상태 업데이트해줘", "로드맵 싱크해줘"
- "/sync-roadmap"
- "이슈 진행 상황 반영해줘", "로드맵 진행률 확인해줘"

## 전제조건

- `docs/ssot/dev/deploy-roadmap.md` 파일이 존재해야 한다
- 없으면 실행을 거부하고, `/dev-roadmap` 스킬을 먼저 실행하도록 안내한다
- GitHub 레포가 연결되어 있어야 한다 (`gh repo view`로 확인)

## 실행 단계

### Step 1: 로드맵 파일 읽기 및 이슈 번호 추출

**Actions:**

1. `docs/ssot/dev/deploy-roadmap.md` 파일 존재 여부를 확인한다
2. 파일을 읽고 전체 구조(마일스톤, 에픽, 작업)를 파악한다
3. 문서에서 `#123` 패턴으로 참조된 모든 이슈 번호를 추출한다
4. 이슈 번호가 하나도 없으면 사용자에게 알리고 중단한다:
   - "로드맵에 이슈 번호가 없습니다. `/create-issues`로 이슈를 먼저 생성해주세요."

### Step 2: GitHub Issues 상태 조회

**Actions:**

1. 추출된 각 이슈 번호에 대해 상태를 조회한다:
   ```bash
   gh issue view {number} --json state,title,assignees
   ```

2. 조회 결과에 따라 상태를 분류한다:
   - `state: "CLOSED"` → **완료**
   - `state: "OPEN"` + `assignees`가 1명 이상 → **진행중**
   - `state: "OPEN"` + `assignees`가 비어있음 → **대기**

3. 존재하지 않는 이슈 번호는 별도로 기록한다 (에러 무시, 목록에 추가)

### Step 3: 로드맵 문서 업데이트

**Actions:**

1. 각 작업 행에 상태 인디케이터를 추가/업데이트한다:
   - 완료: 해당 행에 `완료` 표시
   - 진행중: 해당 행에 `진행중` 표시
   - 대기: 해당 행에 `대기` 표시

2. 각 마일스톤 헤더 아래에 진행률을 추가/업데이트한다:
   ```markdown
   ## M1: 핵심 기능
   > 진행률: 3/8 완료 (37%)
   ```

3. 문서 최상단에 마지막 동기화 시각을 추가/업데이트한다:
   ```markdown
   > **마지막 동기화**: YYYY-MM-DD HH:MM
   ```

4. 존재하지 않는 이슈가 있었다면 문서 하단에 경고를 추가한다:
   ```markdown
   > ⚠️ 조회 실패한 이슈: #999, #1000 (삭제되었거나 번호가 잘못되었을 수 있음)
   ```

### Step 4: 커밋 및 푸시

**Actions:**

1. 변경된 `docs/ssot/dev/deploy-roadmap.md`를 커밋한다:
   ```bash
   git add docs/ssot/dev/deploy-roadmap.md
   git commit -m "docs: 로드맵 진행 상황 동기화 (YYYY-MM-DD)"
   git push
   ```

### Step 5: 결과 요약

**Actions:**

사용자에게 변경 요약을 보여준다:

```markdown
## 로드맵 동기화 완료

| 마일스톤 | 완료 | 진행중 | 대기 | 진행률 |
|----------|------|--------|------|--------|
| M0 | 3 | 0 | 0 | 100% |
| M1 | 2 | 1 | 5 | 25% |
| M2 | 0 | 0 | 4 | 0% |
| **전체** | **5** | **1** | **9** | **33%** |

### 변경 내역
- 완료로 변경: #12 프로젝트 초기화, #15 DB 스키마 작성
- 진행중으로 변경: #18 인증 구현
- 조회 실패: (없음)
```

---

## 모델 선택 가이드

- 이슈 상태 조회 + 문서 업데이트: `sonnet` (패턴 매칭, 구조화된 문서 편집)

---

## 품질 체크리스트

- [ ] `docs/ssot/dev/deploy-roadmap.md` 파일 존재를 확인했는가?
- [ ] 로드맵의 모든 이슈 번호를 빠짐없이 추출했는가?
- [ ] 존재하지 않는 이슈 번호를 안전하게 처리했는가?
- [ ] 상태 인디케이터가 정확하게 반영되었는가? (CLOSED→완료, OPEN+assigned→진행중, OPEN+unassigned→대기)
- [ ] 각 마일스톤별 진행률이 정확하게 계산되었는가?
- [ ] 마지막 동기화 시각이 업데이트되었는가?
- [ ] 변경 요약이 사용자에게 표시되었는가?
- [ ] 커밋 및 푸시가 완료되었는가?

---

## 관련 스킬

- `dev-roadmap` - 배포 로드맵 생성 (선행)
- `create-issues` - GitHub Issues 생성 (선행)
