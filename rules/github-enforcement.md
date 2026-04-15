# GitHub 규칙 강제 및 대응

## 원칙

GitHub 인프라(Actions, Branch Protection, Git Hooks)가 규칙을 강제한다.
Claude Code는 규칙을 "지키려고 노력"하는 게 아니라, "막히면 읽고 고치는" 방식으로 동작한다.

## 규칙 목록 (GitHub이 강제)

1. **PR에 이슈 연결 필수** — PR 본문에 `closes #N` 없으면 체크 실패
2. **이슈에 라벨 필수** — claude-task 또는 human-task 라벨 없으면 체크 실패
3. **이슈에 마일스톤 필수** — 마일스톤 없으면 체크 실패
4. **main 직접 머지 금지** — develop 또는 release/ 브랜치에서만 main으로 머지 가능
5. **커밋 메시지에 이슈 번호** — `#N` 없으면 pre-push hook이 reject

## 막혔을 때 대응 (필수)

push나 PR이 실패하면, 에러 메시지를 **반드시 읽고** 메시지에 적힌 "해결 방법"을 그대로 실행한다.
추측으로 해결하려 하지 말고, 에러 메시지가 시키는 걸 한다.

### 패턴 1: pre-push hook 실패

```
=== 커밋 메시지 규칙 체크 실패 ===
❌ abc1234: 로그인 화면 구현
   해결 방법: git commit --amend -m "로그인 화면 구현 (#12)"
```

→ 에러에 적힌 `git commit --amend` 명령어를 실행한다. 그 다음 다시 push.

### 패턴 2: PR 체크 실패 — 이슈 미연결

```
❌ PR에 연결된 이슈가 없습니다.
   해결 방법: PR 본문에 "closes #이슈번호"를 추가하세요.
```

→ `gh pr edit {PR번호} --body "기존본문\n\ncloses #이슈번호"` 실행.

### 패턴 3: PR 체크 실패 — 이슈 라벨 없음

```
❌ 이슈 #42에 작업 라벨이 없습니다.
   해결 방법: gh issue edit 42 --add-label "claude-task"
```

→ 에러에 적힌 `gh issue edit` 명령어를 실행한다.

### 패턴 4: PR 체크 실패 — 마일스톤 없음

```
❌ 이슈 #42에 마일스톤이 없습니다.
   해결 방법: gh issue edit 42 --milestone "v0.1.0"
```

→ 에러에 적힌 명령어를 실행한다. 마일스톤이 뭔지 모르면 `gh api repos/{owner}/{repo}/milestones`로 확인.

### 패턴 5: main 직접 머지 시도

```
❌ main 브랜치에 직접 머지할 수 없습니다.
   해결 방법: develop 브랜치로 PR 대상을 변경하세요.
```

→ `gh pr edit {PR번호} --base develop` 실행.

## 절대 하면 안 되는 것

- `--no-verify`로 hook 우회 금지
- `--force`로 protection 무시 금지
- 에러를 무시하고 다른 방법으로 우회 금지
- 에러 메시지를 읽지 않고 추측으로 해결 시도 금지
