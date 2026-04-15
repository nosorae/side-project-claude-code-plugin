#!/bin/bash
# SSOT 문서 변경 시 product-blueprint.html 업데이트 리마인더
# PostToolUse hook: Write/Edit 도구가 SSOT 경로 파일을 수정하면 알림

INPUT=$(cat)

# PostToolUse 이벤트만 처리
EVENT_TYPE=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)
if [ "$EVENT_TYPE" != "PostToolUse" ]; then
  exit 0
fi

# Write/Edit 도구만 처리
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ]; then
  exit 0
fi

# 파일 경로 추출
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# product-blueprint.html 자체 수정은 무시
if echo "$FILE_PATH" | grep -q "product-blueprint.html"; then
  exit 0
fi

# SSOT 경로 패턴 매칭
if echo "$FILE_PATH" | grep -qE "docs/ssot/(prd|design|dev)/"; then
  # 어떤 탭을 업데이트해야 하는지 결정
  TAB=""
  if echo "$FILE_PATH" | grep -q "docs/ssot/prd/"; then
    TAB="기획"
  elif echo "$FILE_PATH" | grep -q "docs/ssot/design/system/"; then
    TAB="디자인시스템"
  elif echo "$FILE_PATH" | grep -q "docs/ssot/design/screens/"; then
    TAB="화면디자인"
  elif echo "$FILE_PATH" | grep -q "docs/ssot/dev/dev-plan"; then
    TAB="개발"
  elif echo "$FILE_PATH" | grep -q "docs/ssot/dev/deploy-roadmap"; then
    TAB="로드맵"
  fi

  if [ -n "$TAB" ]; then
    echo "[Blueprint 리마인더] SSOT 문서가 변경되었습니다: $(basename "$FILE_PATH")"
    echo "→ /product-blueprint --tab=${TAB} 실행이 필요합니다."
  fi
fi
