#!/bin/bash
# 동반 플러그인 자동 설치
# 세션 첫 프롬프트에서 누락된 플러그인을 감지하고 바로 설치한다.

INPUT=$(cat)

EVENT_TYPE=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)
if [ "$EVENT_TYPE" != "UserPromptSubmit" ]; then
  exit 0
fi

# 세션당 1회만 실행
FLAG_DIR="/tmp/claude-plugin-check"
mkdir -p "$FLAG_DIR"
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
FLAG_FILE="$FLAG_DIR/${SESSION_ID:-default}"

if [ -f "$FLAG_FILE" ]; then
  exit 0
fi
touch "$FLAG_FILE"

INSTALLED=0

# superpowers
if ! claude plugin list 2>/dev/null | grep -q "superpowers"; then
  echo "[자동 설치] superpowers (구현 워크플로우)..."
  claude plugin install superpowers@claude-plugins-official --scope project 2>/dev/null && INSTALLED=$((INSTALLED+1))
fi

# slavingia/skills
if ! claude plugin list 2>/dev/null | grep -q "skills"; then
  echo "[자동 설치] slavingia/skills (아이디어 검증)..."
  claude plugin install skills@slavingia/skills --scope project 2>/dev/null && INSTALLED=$((INSTALLED+1))
fi

# phuryn/pm-skills
if ! claude plugin list 2>/dev/null | grep -q "pm-skills"; then
  echo "[자동 설치] phuryn/pm-skills (PM/인터뷰)..."
  claude plugin install pm-skills@phuryn/pm-skills --scope project 2>/dev/null && INSTALLED=$((INSTALLED+1))
fi

# garrytan/gstack
if ! claude plugin list 2>/dev/null | grep -q "gstack"; then
  echo "[자동 설치] garrytan/gstack (작업 관리)..."
  claude plugin install gstack@garrytan/gstack --scope project 2>/dev/null && INSTALLED=$((INSTALLED+1))
fi

if [ "$INSTALLED" -gt 0 ]; then
  echo "[완료] 동반 플러그인 ${INSTALLED}개 설치됨. /reload-plugins 로 적용하세요."
fi
