#!/bin/bash
# 동반 플러그인 자동 설치 체크
# UserPromptSubmit hook으로 매 프롬프트마다 실행되지만,
# 이미 체크한 세션에서는 플래그 파일로 스킵

INPUT=$(cat)

EVENT_TYPE=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)
if [ "$EVENT_TYPE" != "UserPromptSubmit" ]; then
  exit 0
fi

# 세션당 1회만 체크 (플래그 파일)
FLAG_DIR="/tmp/claude-plugin-check"
mkdir -p "$FLAG_DIR"
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
FLAG_FILE="$FLAG_DIR/${SESSION_ID:-default}"

if [ -f "$FLAG_FILE" ]; then
  exit 0
fi
touch "$FLAG_FILE"

# 동반 플러그인 체크 및 설치 안내
MISSING=""

# superpowers 체크
if ! claude plugin list 2>/dev/null | grep -q "superpowers"; then
  MISSING="$MISSING
  - superpowers (구현 워크플로우): /plugin install superpowers@claude-plugins-official"
fi

# slavingia/skills 체크
if ! claude plugin list 2>/dev/null | grep -q "skills"; then
  MISSING="$MISSING
  - slavingia/skills (아이디어 검증): /plugin marketplace add slavingia/skills && claude plugin install skills --scope project"
fi

# phuryn/pm-skills 체크
if ! claude plugin list 2>/dev/null | grep -q "pm-skills"; then
  MISSING="$MISSING
  - phuryn/pm-skills (PM/인터뷰): /plugin marketplace add phuryn/pm-skills && claude plugin install pm-skills --scope project"
fi

# garrytan/gstack 체크
if ! claude plugin list 2>/dev/null | grep -q "gstack"; then
  MISSING="$MISSING
  - garrytan/gstack (작업 관리): /plugin marketplace add garrytan/gstack && claude plugin install gstack --scope project"
fi

if [ -n "$MISSING" ]; then
  echo "[Side Project Setup] 동반 플러그인이 설치되지 않았습니다:"
  echo "$MISSING"
  echo ""
  echo "한번에 설치하려면: bash \$(claude plugin path side-project-claude-settings 2>/dev/null || echo .)/install-all.sh"
fi
