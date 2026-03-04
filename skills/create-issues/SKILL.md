---
description: 배포 로드맵을 기반으로 GitHub Issues를 자동 생성하는 스킬. 에픽 이슈 + 하위 작업 이슈 구조, claude-task/human-task 라벨 자동 부여
---

# Create Issues (GitHub Issues 생성)

배포 로드맵(`docs/ssot/deploy-roadmap.md`)을 분석하여 GitHub Issues를 자동 생성하는 스킬입니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "이슈 만들어줘", "GitHub Issues 생성해줘"
- "/create-issues"
- "로드맵 기반으로 작업 분배해줘"

## 전제조건

- `docs/ssot/deploy-roadmap.md` 파일이 존재해야 한다
- GitHub 레포가 연결되어 있어야 한다 (`gh repo view`로 확인)
- 없으면 실행을 거부하고, 필요한 선행 작업을 안내한다

## 실행 단계

### Step 1: 사전 준비

**Actions:**

1. `docs/ssot/deploy-roadmap.md`를 읽고 마일스톤/에픽/작업 구조를 파악한다
2. GitHub 레포 연결 상태를 확인한다: `gh repo view`
3. 필요한 라벨이 존재하는지 확인하고, 없으면 생성한다:
   ```bash
   gh label create "epic" --description "에픽 이슈" --color "6f42c1"
   gh label create "claude-task" --description "Claude Code가 독립 수행 가능한 작업" --color "0075ca"
   gh label create "human-task" --description "사람이 직접 수행해야 하는 작업" --color "e4e669"
   ```

### Step 2: 사용자 싱크

**이슈 생성 전 반드시 사용자와 대화로 합의한다.**

**Actions:**

1. 로드맵에서 추출한 이슈 목록을 요약하여 보여준다:
   - 마일스톤별 에픽 수
   - 에픽별 하위 작업 수
   - claude-task / human-task 비율
2. 사용자에게 확인한다:
   - "이 구조로 이슈를 생성할까요?"
   - "수정하거나 추가할 작업이 있나요?"
   - "작업 분류(claude-task/human-task)가 적절한가요?"
3. 사용자 피드백을 반영하여 최종 이슈 목록을 확정한다

### Step 3: 에픽 이슈 생성

**Actions:**

마일스톤별로 에픽 이슈를 먼저 생성한다:

```bash
gh issue create \
  --title "[M0] Epic: 개발 환경 구성" \
  --label "epic" \
  --body "$(cat <<'EOF'
## 마일스톤
M0: 프로젝트 셋업

## 하위 작업
- [ ] #(하위이슈번호) 작업 1
- [ ] #(하위이슈번호) 작업 2

## 완료 기준
- [ ] 모든 하위 작업 완료
- [ ] 검증 통과
EOF
)"
```

### Step 4: 하위 작업 이슈 생성

**Actions:**

각 에픽의 하위 작업을 이슈로 생성한다. 타입에 따라 템플릿이 다르다.

**claude-task 이슈:**
```bash
gh issue create \
  --title "프로젝트 초기화 및 기본 구조 셋업" \
  --label "claude-task" \
  --body "$(cat <<'EOF'
## 맥락
- 상위 에픽: #(에픽번호) [M0] Epic: 개발 환경 구성
- 관련 문서: docs/ssot/dev-plan.md
- 전체 흐름 내 위치: (없음) → **이 작업** → 환경변수 설정

## 할일
- [ ] Next.js 프로젝트 생성
- [ ] Tailwind CSS 설정
- [ ] 디렉토리 구조 생성
- [ ] ESLint/Prettier 설정

## 검증 방법
- [ ] `npm run dev`로 개발 서버 정상 실행
- [ ] 기본 페이지 렌더링 확인
EOF
)"
```

**human-task 이슈:**
```bash
gh issue create \
  --title "Supabase 프로젝트 생성 및 초기 설정" \
  --label "human-task" \
  --body "$(cat <<'EOF'
## 목적
백엔드 DB와 인증을 위한 Supabase 프로젝트가 필요합니다.

## 단계별 가이드
- [ ] Step 1: Supabase 대시보드에서 새 프로젝트 생성 → [Supabase Dashboard](https://supabase.com/dashboard)
- [ ] Step 2: 프로젝트 URL과 anon key 복사
- [ ] Step 3: `.env.local` 파일에 환경변수 추가

## 완료 기준
- [ ] Supabase 프로젝트가 생성되어 접근 가능
- [ ] 환경변수가 `.env.local`에 설정됨
EOF
)"
```

### Step 5: 에픽 이슈 업데이트

**Actions:**

하위 이슈가 모두 생성된 후, 에픽 이슈의 본문을 업데이트하여 실제 이슈 번호를 연결한다:

```bash
gh issue edit {에픽번호} --body "업데이트된 본문(실제 이슈 번호 포함)"
```

### Step 6: 결과 보고

**Actions:**

생성된 이슈 요약을 사용자에게 보여준다:

```markdown
## 생성 완료

| 마일스톤 | 에픽 | 하위 작업 | claude-task | human-task |
|----------|------|----------|-------------|------------|
| M0 | 1 | 3 | 2 | 1 |
| M1 | 2 | 8 | 7 | 1 |
| ... | ... | ... | ... | ... |
| **합계** | **N** | **N** | **N** | **N** |

### 추천 작업 순서
1. human-task부터 시작 (병목 제거): #이슈번호, #이슈번호
2. claude-task 병렬 수행: #이슈번호, #이슈번호
```

Git 커밋 + 푸시 (로드맵에 이슈 번호 매핑 추가)

---

## 모델 선택 가이드

- 로드맵 분석 + 이슈 구성: `sonnet` (구조화된 분석)
- 이슈 본문 작성: `sonnet` (템플릿 기반 문서 작성)

---

## 품질 체크리스트

- [ ] 로드맵의 모든 작업이 이슈로 생성되었는가?
- [ ] 모든 이슈에 적절한 라벨이 부여되었는가?
- [ ] 에픽 이슈에 하위 작업 링크가 정확한가?
- [ ] claude-task 이슈가 독립 수행 가능한 수준으로 작성되었는가?
- [ ] human-task 이슈에 외부 서비스 링크가 포함되었는가?
- [ ] 의존성 순서가 이슈 본문에 반영되었는가?
- [ ] 사용자와 이슈 구조를 합의했는가?

---

## 관련 스킬

- `dev-roadmap` - 배포 로드맵 생성 (선행)
