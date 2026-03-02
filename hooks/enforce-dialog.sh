#!/bin/bash
# Stop hook: 유의미한 작업 커밋이 있는데 docs/dialogs/ 기록이 없으면 종료 차단

WORK=$(git log --oneline --since="4 hours ago" -- . ":!docs/dialogs" 2>/dev/null | wc -l | tr -d ' ')
DIALOG=$(git log --oneline --since="4 hours ago" -- "docs/dialogs/" 2>/dev/null | wc -l | tr -d ' ')

if [ "$WORK" -gt 0 ] && [ "$DIALOG" -eq 0 ]; then
    echo "[히스토리 기록 필요] 최근 작업 커밋(${WORK}건)이 있지만 docs/dialogs/ 에 대화 기록이 없습니다."
    echo "대화 기록을 작성하고 커밋+푸시한 후 종료해주세요."
    exit 1
fi
