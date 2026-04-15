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

### Step 1: GitHub 인프라 세팅

**Actions:**

이슈를 만들기 전에 규칙이 강제되는 환경을 먼저 만든다.

1. `docs/ssot/dev/deploy-roadmap.md`를 읽고 마일스톤/에픽/작업 구조를 파악한다
2. GitHub 레포 연결 상태를 확인한다: `gh repo view`

3. **라벨 생성:**
   ```bash
   gh label create "epic" --description "에픽 이슈" --color "6f42c1" 2>/dev/null || true
   gh label create "claude-task" --description "Claude Code가 독립 수행 가능한 작업" --color "0075ca" 2>/dev/null || true
   gh label create "human-task" --description "사람이 직접 수행해야 하는 작업" --color "e4e669" 2>/dev/null || true
   gh label create "priority/now" --description "지금 해야 함" --color "d73a4a" 2>/dev/null || true
   gh label create "priority/next" --description "다음에 할 것" --color "fbca04" 2>/dev/null || true
   gh label create "priority/later" --description "나중에" --color "0e8a16" 2>/dev/null || true
   ```

4. **마일스톤 생성 (버전 기반):**
   로드맵의 마일스톤을 실제 GitHub 마일스톤으로 생성한다. M0~M3 대신 릴리스 버전을 사용한다.
   ```bash
   # 예시: MVP 기준
   gh api repos/{owner}/{repo}/milestones -f title="v0.1.0" -f description="MVP — 핵심 기능만"
   gh api repos/{owner}/{repo}/milestones -f title="v0.2.0" -f description="보조 기능 + 개선"
   gh api repos/{owner}/{repo}/milestones -f title="v1.0.0" -f description="정식 릴리스"
   ```
   버전 이름과 설명은 로드맵 내용에 맞게 조정한다.

5. **GitHub Actions 워크플로우 복사:**
   플러그인의 `templates/.github/` 디렉토리를 프로젝트에 복사한다.
   ```bash
   cp -r ${CLAUDE_PLUGIN_ROOT}/templates/.github/ .github/
   ```
   이 워크플로우가 PR마다 자동 실행되어 규칙을 강제한다:
   - PR에 이슈 연결 없으면 → 체크 실패
   - 이슈에 라벨 없으면 → 체크 실패
   - 이슈에 마일스톤 없으면 → 체크 실패
   - main 직접 머지 시도하면 → 체크 실패

6. **이슈 템플릿 복사:**
   위 `.github/` 복사에 이미 포함됨. claude-task, human-task 템플릿이 GitHub 이슈 생성 UI에 자동 적용된다.

7. **pre-push hook 설치:**
   ```bash
   cp ${CLAUDE_PLUGIN_ROOT}/templates/hooks/pre-push .git/hooks/pre-push
   chmod +x .git/hooks/pre-push
   ```
   커밋 메시지에 이슈 번호(#N) 없으면 push를 reject한다.

8. **Branch Protection 설정:**
   ```bash
   gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
     -f "required_status_checks[strict]=true" \
     -f "required_status_checks[contexts][]=check-pr-rules" \
     -f "enforce_admins=true" \
     -f "required_pull_request_reviews[required_approving_review_count]=0" \
     -f "restrictions=null"
   ```
   main 브랜치에 직접 push 불가, PR 체크 통과 필수.

9. **Projects 보드 생성:**
   ```bash
   gh project create --title "{프로젝트이름}" --owner @me
   ```
   컬럼: Backlog → In Progress → Review → Done
   이슈가 닫히면 자동으로 Done으로 이동하도록 설정.

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
3. **기술 선정 근거** (해당하는 경우): 이 작업에서 특정 기술/라이브러리/패턴을 쓰는 이유. 대안이 뭐였고 왜 이걸 골랐는지. 나중에 "왜 이렇게 했지?"라고 물었을 때 답이 되어야 한다
4. **입력/출력**: 이 작업의 입력은 뭐고 출력은 뭔지
5. **검증 방법**: 어떤 명령어를 실행해서 어떤 결과가 나오면 완료인지
6. **참고할 문서**: dev-plan, 베스트 프랙티스 스킬 등 참조할 문서 경로

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

## 기술 선정 근거
- **Next.js 14 (App Router)**: Pages Router 대비 서버 컴포넌트로 초기 로딩 빠름. AI 코딩과 호환성 좋음 (파일 기반 라우팅이 명확해서)
- **Tailwind CSS**: styled-components 대비 빌드 없이 즉시 반영, AI가 생성하기 쉬움
- **src/ 디렉토리**: 루트가 지저분해지는 것 방지. Next.js 공식 권장 구조

## 디렉토리 구조
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
4. **대안과 트레이드오프** (해당하는 경우): 이 서비스를 고른 이유, 다른 대안은 뭐가 있는지, 각각의 장단점. 예: "Supabase 대신 Firebase도 가능 — Firebase는 NoSQL이라 관계형 데이터에 불편, Supabase는 PostgreSQL 기반이라 SQL 가능, 무료 티어 넉넉"
5. **흔한 실수/주의사항**: 이 단계에서 자주 틀리는 것
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

### 왜 Supabase인가 (대안과 트레이드오프)
| 서비스 | 장점 | 단점 | 결론 |
|--------|------|------|------|
| **Supabase** | PostgreSQL 기반 SQL, 무료 티어 넉넉, Auth+Storage 통합 | 서버리스 함수 제한적 | 사이드 프로젝트에 가장 적합 |
| Firebase | 실시간 DB, 풍부한 모바일 SDK | NoSQL이라 관계형 데이터 불편, 무료 티어 제한 | 모바일 앱이면 고려 |
| PlanetScale | MySQL 호환, 브랜칭 | Auth/Storage 별도 구축 필요 | DB만 필요할 때 |

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
