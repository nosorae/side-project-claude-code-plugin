#!/bin/bash
# Side Project Claude Settings — 전체 플러그인 한번에 설치
# 이 플러그인 + 동반 플러그인 4개를 모두 설치합니다.

echo "=== Side Project Claude Settings 전체 설치 ==="
echo ""

# 1. 이 플러그인
echo "[1/5] side-project-claude-code-plugin 설치 중..."
claude plugin install side-project-claude-code-plugin@side-project-claude-settings --scope project 2>/dev/null || {
  echo "  -> 마켓플레이스 등록 후 재시도..."
  claude plugin marketplace add nosorae/side-project-claude-settings --scope project 2>/dev/null
  claude plugin install side-project-claude-code-plugin@side-project-claude-settings --scope project
}

# 2. superpowers (구현 워크플로우)
echo "[2/5] superpowers 설치 중..."
claude plugin install superpowers@claude-plugins-official --scope project 2>/dev/null || echo "  -> 이미 설치됨 또는 수동 설치 필요"

# 3. slavingia/skills (아이디어 검증)
echo "[3/5] slavingia/skills 설치 중..."
claude plugin install skills@slavingia/skills --scope project 2>/dev/null || {
  claude plugin marketplace add slavingia/skills --scope project 2>/dev/null
  claude plugin install skills --scope project 2>/dev/null || echo "  -> 수동 설치 필요"
}

# 4. phuryn/pm-skills (PM/인터뷰)
echo "[4/5] phuryn/pm-skills 설치 중..."
claude plugin install pm-skills@phuryn/pm-skills --scope project 2>/dev/null || {
  claude plugin marketplace add phuryn/pm-skills --scope project 2>/dev/null
  claude plugin install pm-skills --scope project 2>/dev/null || echo "  -> 수동 설치 필요"
}

# 5. garrytan/gstack (작업 관리)
echo "[5/5] garrytan/gstack 설치 중..."
claude plugin install gstack@garrytan/gstack --scope project 2>/dev/null || {
  claude plugin marketplace add garrytan/gstack --scope project 2>/dev/null
  claude plugin install gstack --scope project 2>/dev/null || echo "  -> 수동 설치 필요"
}

echo ""
echo "=== 설치 완료 ==="
echo "\"앱 기획해줘\" 또는 /app-plan 으로 시작하세요."
