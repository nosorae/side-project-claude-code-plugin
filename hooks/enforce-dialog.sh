#!/bin/bash
# Stop hook: 유의미한 작업 커밋이 있는데 docs/handoff/ 기록이 없으면 종료 차단

WORK=$(git log --oneline --since="4 hours ago" -- . ":!docs/handoff" 2>/dev/null | wc -l | tr -d ' ')
HANDOFF=$(git log --oneline --since="4 hours ago" -- "docs/handoff/" 2>/dev/null | wc -l | tr -d ' ')

if [ "$WORK" -gt 0 ] && [ "$HANDOFF" -eq 0 ]; then
    echo "[핸드오프 필요] 최근 작업 커밋(${WORK}건)이 있지만 docs/handoff/ 에 핸드오프 문서가 없습니다."
    echo "핸드오프 문서를 작성하고 커밋+푸시한 후 종료해주세요."
    exit 1
fi
