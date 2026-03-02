---
description: Git Sync - 원격 저장소에서 최신 변경사항을 가져오고 변경 내역 파악
user_invocable: true
---

# Git Sync

원격 저장소에서 최신 변경사항을 가져오고 변경 내역을 파악합니다.
"리모트 당겨줘", "pull 해줘", "최신화 해줘" 등의 요청 시 이 스킬을 사용합니다.

## 인자

- `$ARGUMENTS`: 조회할 기간 (예: "3 days", "1 week")
  - 기본값: "7 days"

## 실행 순서

### STEP 1: fetch 및 상태 확인

```bash
git fetch origin
```

```bash
git status --porcelain
```

- 로컬 변경사항 유무를 확인한다.

### STEP 2: pull

**로컬 변경사항이 있는 경우:**
```bash
git stash
git pull origin $(git branch --show-current)
```

**로컬 변경사항이 없는 경우:**
```bash
git pull origin $(git branch --show-current)
```

- pull 결과를 확인한다. "Already up to date."이면 STEP 5로 건너뛴다.
- pull에서 충돌이 발생하면 STEP 4로 간다.

### STEP 3: stash pop (로컬 변경사항이 있었던 경우만)

```bash
git stash pop
```

- stash pop에서 충돌이 발생하면 STEP 4로 간다.
- 충돌 없으면 STEP 5로 간다.

### STEP 4: 충돌 해결 (충돌 발생 시에만)

충돌이 발생하면 **절대 자동으로 해결하지 말고** 사용자에게 물어본다.

1. 충돌 파일 목록 확인:
```bash
git diff --name-only --diff-filter=U
```

2. 각 충돌 파일을 Read 도구로 읽어서 충돌 마커(`<<<<<<<`, `=======`, `>>>>>>>`) 부분을 사용자에게 보여준다.

3. **각 파일마다** AskUserQuestion으로 해결 방법을 물어본다:
   - **로컬 유지 (ours)**: 내 로컬 변경사항을 유지
   - **리모트 수용 (theirs)**: 원격 변경사항을 수용
   - **직접 수정**: 사용자가 직접 내용을 알려주면 Edit 도구로 반영

4. 선택에 따라 실행:
   - ours: `git checkout --ours <파일>` 후 `git add <파일>`
   - theirs: `git checkout --theirs <파일>` 후 `git add <파일>`
   - 직접 수정: 사용자 지시에 따라 Edit 후 `git add <파일>`

5. 모든 충돌 해결 후 머지 커밋:
```bash
git commit -m "Merge: resolve conflicts from origin"
```

### STEP 5: 결과 표시

최근 커밋 내역을 표시한다. `$ARGUMENTS`가 있으면 해당 기간, 없으면 7일:

```bash
git log --oneline --since="7 days ago" --format="%h %ad %s" --date=short
```

## 출력 형식

```markdown
## 최신화 완료

**새로 가져온 커밋:**
| 해시 | 날짜 | 메시지 |
|------|------|--------|
| abc123 | 2026-01-21 | 커밋 메시지 |

**충돌 해결:** (있었다면)
- 파일명: 해결 방법 (ours/theirs/직접수정)
```

변경사항이 없었다면:
```markdown
## 최신화 완료

이미 최신 상태입니다. 새로운 변경사항이 없습니다.
```
