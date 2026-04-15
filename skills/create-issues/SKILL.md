---
name: create-issues
description: |
  배포 로드맵을 기반으로 GitHub Issues를 자동 생성하는 스킬. 에픽 이슈 + 하위 작업 이슈 구조, claude-task/human-task 라벨 자동 부여.
  이 스킬은 다음과 같은 요청에 반드시 사용한다: "이슈 만들어줘", "GitHub 이슈 생성", "작업 분배", "태스크 생성", "/create-issues", "에픽 이슈 만들어줘".
  로드맵이 완성되어 구현 작업을 이슈로 분해해야 하는 맥락이면 이 스킬을 사용한다.
user_invocable: true
---

# Create Issues (GitHub Issues 생성)

배포 로드맵(`docs/ssot/dev/deploy-roadmap.md`)을 분석하여 GitHub Issues를 자동 생성하는 스킬입니다.

## 트리거 조건

다음과 같은 요청이 들어올 때 자동 발동:
- "이슈 만들어줘", "GitHub Issues 생성해줘"
- "/create-issues"
- "로드맵 기반으로 작업 분배해줘"

## 전제조건

- **GitHub CLI**: `gh --version`으로 확인. 미설치 시 macOS는 `brew install gh` 자동 시도, 그 외 OS는 설치 안내 후 중단. 미로그인 시 `gh auth login` 안내.
- `docs/ssot/dev/deploy-roadmap.md` 파일이 존재해야 한다
  - **없으면**:
    ```
    ⚠️ 이 스킬을 실행하려면 먼저 `/dev-roadmap`으로 배포 로드맵을 작성해야 합니다.

    선택하세요:
    a) /dev-roadmap 먼저 실행 (권장)
    b) --skip으로 전제조건 건너뛰고 진행 (비권장)
    ```
- GitHub 레포가 연결되어 있어야 한다 (`gh repo view`로 확인)

## 실행 단계

### Step 1: 사전 준비

**Actions:**

1. `docs/ssot/dev/deploy-roadmap.md`를 읽고 마일스톤/에픽/작업 구조를 파악한다
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

**claude-task 이슈 — 어떤 LLM이 와도 동일하게 구현할 수 있을 만큼 명확하게:**

이슈 본문에 반드시 포함해야 하는 항목:
1. **맥락**: 상위 에픽, 관련 문서 경로, 이 작업의 전후 의존성
2. **구현 스펙**: 구체적으로 어떤 파일을 만들고, 어떤 코드를 쓰고, 어떤 설정을 해야 하는지. "설정해라"가 아니라 "이 값으로 설정해라"
3. **입력/출력**: 이 작업의 입력은 뭐고 출력은 뭔지
4. **검증 방법**: 어떤 명령어를 실행해서 어떤 결과가 나오면 완료인지
5. **참고할 문서**: dev-plan, 베스트 프랙티스 스킬 등 참조할 문서 경로

```bash
gh issue create \
  --title "프로젝트 초기화 및 기본 구조 셋업" \
  --label "claude-task" \
  --body "$(cat <<'EOF'
## 맥락
- 상위 에픽: #(에픽번호) [M0] Epic: 개발 환경 구성
- 관련 문서: docs/ssot/dev/dev-plan.md (디렉토리 구조 섹션)
- 의존성: (없음) → **이 작업** → #(다음이슈) 환경변수 설정

## 구현 스펙
- `npx create-next-app@14 . --typescript --tailwind --eslint --app --src-dir` 실행
- `src/` 아래 다음 디렉토리 생성:
  - `src/components/ui/` — 공유 UI 컴포넌트
  - `src/lib/` — 유틸리티 함수
  - `src/hooks/` — 커스텀 훅
  - `src/types/` — 타입 정의
- `.prettierrc`에 `{ "semi": false, "singleQuote": true, "tabWidth": 2 }` 설정
- `next.config.ts`에 이미지 도메인 설정: `images: { domains: [] }`

## 검증 방법
- [ ] `npm run dev` → localhost:3000 접속 → 기본 페이지 렌더링
- [ ] `npm run build` → 에러 없이 빌드 완료
- [ ] `npm run lint` → 경고/에러 없음
- [ ] `src/components/ui/`, `src/lib/`, `src/hooks/`, `src/types/` 디렉토리 존재
EOF
)"
```

**human-task 이슈 — 개발 경험이 없는 사람도 따라할 수 있게 스텝바이스텝으로:**

이슈 본문에 반드시 포함해야 하는 항목:
1. **왜 이걸 해야 하는지**: 이 작업이 전체에서 어떤 역할인지 한 줄 설명
2. **스텝바이스텝 가이드**: 스크린샷 위치까지 설명하는 수준. "생성해라"가 아니라 "어디를 클릭해서 뭘 입력해라"
3. **선택지가 있으면 추천과 이유**: "리전을 고르라는데 뭘 골라야 하지?" → "Northeast Asia(ap-northeast-1) 추천, 한국에서 레이턴시 가장 낮음"
4. **흔한 실수/주의사항**: 이 단계에서 자주 틀리는 것
5. **완료 후 다음 단계**: 이 결과물을 어디에 넣어야 하는지

```bash
gh issue create \
  --title "Supabase 프로젝트 생성 및 초기 설정" \
  --label "human-task" \
  --body "$(cat <<'EOF'
## 왜 필요한가
앱의 데이터베이스와 사용자 인증을 Supabase로 처리합니다.
이 작업이 끝나야 #(다음이슈) 환경변수 설정을 진행할 수 있습니다.

## 스텝바이스텝 가이드

### Step 1: Supabase 프로젝트 생성
1. [supabase.com/dashboard](https://supabase.com/dashboard) 접속 → 로그인 (GitHub 계정으로 가능)
2. "New Project" 클릭
3. 입력 항목:
   - **Project name**: `{프로젝트이름}` (kebab-case)
   - **Database Password**: 강력한 비밀번호 입력 → 따로 메모해둘 것 (나중에 다시 볼 수 없음)
   - **Region**: Northeast Asia (ap-northeast-1) 선택 — 한국에서 레이턴시 가장 낮음
   - **Plan**: Free tier (사이드 프로젝트라면 충분)
4. "Create new project" 클릭 → 2~3분 대기

### Step 2: 키 복사
1. 프로젝트 대시보드 → 좌측 메뉴 Settings → API
2. 다음 두 값을 복사:
   - **Project URL**: `https://xxx.supabase.co` 형태
   - **anon public key**: `eyJ...` 형태 (길이가 매우 긴 문자열)

### Step 3: 환경변수 파일에 추가
프로젝트 루트에 `.env.local` 파일을 만들고:
```
NEXT_PUBLIC_SUPABASE_URL=여기에_Project_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=여기에_anon_key
```

### 주의사항
- Database Password를 잊으면 프로젝트를 새로 만들어야 함 — 반드시 메모
- `.env.local`은 `.gitignore`에 이미 포함되어 있어서 커밋되지 않음 (정상)
- anon key는 공개되어도 괜찮음 (Row Level Security로 보호됨). service_role key는 절대 공개하면 안 됨

## 완료 기준
- [ ] Supabase 대시보드에서 프로젝트 상태가 "Active"
- [ ] `.env.local`에 URL과 anon key가 입력됨
- [ ] 다음 이슈(#다음이슈)에서 이 값을 사용할 준비 완료
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
- [ ] claude-task: 다른 LLM이 이 이슈만 보고 동일하게 구현할 수 있는가? (구체적 파일명, 설정값, 검증 명령어 포함)
- [ ] human-task: 개발 경험 없는 사람이 스텝바이스텝으로 따라할 수 있는가? (클릭 위치, 추천 선택지, 주의사항 포함)
- [ ] 의존성 순서가 이슈 본문에 반영되었는가?
- [ ] 사용자와 이슈 구조를 합의했는가?

---

## 관련 스킬

- `dev-roadmap` - 배포 로드맵 생성 (선행)
