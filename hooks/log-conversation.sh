#!/bin/bash
# 대화 기록 자동 로깅 훅
# UserPromptSubmit: 사용자 명령 원문 기록
# PostToolUse: 도구명 + 핵심 입력 + 출력 요약 기록

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
SESSION_SHORT="${SESSION_ID:0:8}"
DATE=$(date +%Y-%m-%d)
LOG_DIR="docs/sessions"
LOG_FILE="${LOG_DIR}/${DATE}-${SESSION_SHORT}.md"

# 로그 디렉토리 생성
mkdir -p "$LOG_DIR"

# 로그 파일이 없으면 헤더 생성
if [ ! -f "$LOG_FILE" ]; then
  echo "# Session Log: ${DATE} (${SESSION_SHORT})" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
fi

# stdin에서 JSON 읽기
INPUT=$(cat)

# 이벤트 타입 파싱
EVENT_TYPE=$(echo "$INPUT" | jq -r '.event // empty' 2>/dev/null)
TIMESTAMP=$(date +%H:%M:%S)

case "$EVENT_TYPE" in
  "UserPromptSubmit")
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
    if [ -n "$PROMPT" ]; then
      echo "## [$TIMESTAMP] User" >> "$LOG_FILE"
      echo "\`\`\`" >> "$LOG_FILE"
      echo "$PROMPT" >> "$LOG_FILE"
      echo "\`\`\`" >> "$LOG_FILE"
      echo "" >> "$LOG_FILE"
    fi
    ;;
  "PostToolUse")
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
    TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty' 2>/dev/null | head -c 200)
    echo "## [$TIMESTAMP] Tool: $TOOL_NAME" >> "$LOG_FILE"
    if [ -n "$TOOL_INPUT" ]; then
      echo "Input: \`${TOOL_INPUT}\`" >> "$LOG_FILE"
    fi
    echo "" >> "$LOG_FILE"
    ;;
esac
