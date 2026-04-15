/**
 * feedback-mode.js
 * 디자인 HTML에서 바로 피드백을 남기고, 구조화된 형태로 복사하는 도구.
 *
 * 사용법:
 *   F키: 피드백 모드 토글
 *   피드백 모드에서 요소 클릭: 메모 입력 팝업
 *   Ctrl+Shift+C: 전체 피드백 클립보드 복사 (Claude Code에 바로 붙여넣기용)
 *   Ctrl+Shift+X: 전체 피드백 초기화
 */
(function() {
  let feedbackMode = false;
  let feedbacks = [];
  let overlay = null;
  let badge = null;
  let highlightedElements = [];

  // 초기화
  function init() {
    createBadge();
    document.addEventListener('keydown', handleKeydown);
  }

  // 상단 배지
  function createBadge() {
    badge = document.createElement('div');
    badge.id = 'fb-badge';
    badge.innerHTML = 'F: 피드백 모드';
    badge.style.cssText = `
      position: fixed; top: 8px; right: 8px; z-index: 99999;
      background: #1a1a2e; color: #8b949e; border: 1px solid #30363d;
      padding: 4px 10px; border-radius: 6px; font-size: 11px;
      font-family: -apple-system, sans-serif; cursor: pointer;
      transition: all 0.2s;
    `;
    badge.onclick = () => toggleMode();
    document.body.appendChild(badge);
  }

  // 모드 토글
  function toggleMode() {
    feedbackMode = !feedbackMode;
    if (feedbackMode) {
      badge.innerHTML = `피드백 모드 ON (${feedbacks.length}개) | Ctrl+Shift+C: 복사`;
      badge.style.background = '#7c3aed';
      badge.style.color = '#fff';
      badge.style.borderColor = '#7c3aed';
      document.body.style.cursor = 'crosshair';
      document.addEventListener('click', handleClick, true);
    } else {
      badge.innerHTML = `F: 피드백 모드 (${feedbacks.length}개)`;
      badge.style.background = feedbacks.length > 0 ? '#1f2937' : '#1a1a2e';
      badge.style.color = feedbacks.length > 0 ? '#34d399' : '#8b949e';
      badge.style.borderColor = feedbacks.length > 0 ? '#374151' : '#30363d';
      document.body.style.cursor = '';
      document.removeEventListener('click', handleClick, true);
    }
  }

  // 요소 클릭 → 피드백 입력
  function handleClick(e) {
    if (!feedbackMode) return;
    const target = e.target;
    if (target.id === 'fb-badge' || target.closest('#fb-popup') || target.closest('.fb-marker')) return;
    e.preventDefault();
    e.stopPropagation();
    showPopup(target, e.clientX, e.clientY);
  }

  // 피드백 입력 팝업
  function showPopup(element, x, y) {
    removePopup();
    const popup = document.createElement('div');
    popup.id = 'fb-popup';
    popup.style.cssText = `
      position: fixed; left: ${Math.min(x, window.innerWidth - 320)}px;
      top: ${Math.min(y, window.innerHeight - 160)}px;
      z-index: 100000; background: #161b22; border: 1px solid #30363d;
      border-radius: 12px; padding: 16px; width: 300px;
      font-family: -apple-system, sans-serif; box-shadow: 0 8px 24px rgba(0,0,0,0.4);
    `;

    const selector = getSelector(element);
    const elementDesc = getElementDescription(element);

    popup.innerHTML = `
      <div style="font-size:11px; color:#8b949e; margin-bottom:8px; word-break:break-all;">
        ${elementDesc}
      </div>
      <textarea id="fb-input" placeholder="피드백을 적으세요..." style="
        width:100%; height:60px; background:#0d1117; color:#e6edf3; border:1px solid #30363d;
        border-radius:8px; padding:8px; font-size:13px; resize:none; outline:none;
        font-family: -apple-system, sans-serif;
      "></textarea>
      <div style="display:flex; gap:8px; margin-top:8px;">
        <button id="fb-save" style="
          flex:1; padding:8px; background:#7c3aed; color:white; border:none;
          border-radius:8px; cursor:pointer; font-size:13px;
        ">저장</button>
        <button id="fb-cancel" style="
          padding:8px 12px; background:none; color:#8b949e; border:1px solid #30363d;
          border-radius:8px; cursor:pointer; font-size:13px;
        ">취소</button>
      </div>
    `;
    document.body.appendChild(popup);

    const input = document.getElementById('fb-input');
    input.focus();

    document.getElementById('fb-save').onclick = () => {
      const text = input.value.trim();
      if (text) {
        const rect = element.getBoundingClientRect();
        feedbacks.push({
          selector: selector,
          description: elementDesc,
          comment: text,
          position: { x: Math.round(rect.left), y: Math.round(rect.top) },
          timestamp: new Date().toLocaleTimeString('ko-KR')
        });
        addMarker(element, feedbacks.length);
        updateBadge();
      }
      removePopup();
    };

    document.getElementById('fb-cancel').onclick = () => removePopup();
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        document.getElementById('fb-save').click();
      }
      if (e.key === 'Escape') removePopup();
    });
  }

  // 피드백 마커 (번호 표시)
  function addMarker(element, num) {
    const rect = element.getBoundingClientRect();
    const marker = document.createElement('div');
    marker.className = 'fb-marker';
    marker.textContent = num;
    marker.style.cssText = `
      position: fixed; left: ${rect.left - 10}px; top: ${rect.top - 10}px;
      width: 20px; height: 20px; background: #f85149; color: white;
      border-radius: 50%; display: flex; align-items: center; justify-content: center;
      font-size: 11px; font-weight: 700; z-index: 99998; pointer-events: none;
      font-family: -apple-system, sans-serif;
    `;
    document.body.appendChild(marker);
    highlightedElements.push(marker);

    element.style.outline = '2px solid #f85149';
    element.style.outlineOffset = '2px';
    highlightedElements.push({ element, originalOutline: '' });
  }

  // CSS 선택자 생성
  function getSelector(el) {
    if (el.id) return '#' + el.id;
    const parts = [];
    while (el && el !== document.body) {
      let selector = el.tagName.toLowerCase();
      if (el.className && typeof el.className === 'string') {
        const classes = el.className.trim().split(/\s+/).slice(0, 2).join('.');
        if (classes) selector += '.' + classes;
      }
      const parent = el.parentElement;
      if (parent) {
        const siblings = Array.from(parent.children).filter(c => c.tagName === el.tagName);
        if (siblings.length > 1) {
          selector += ':nth-child(' + (Array.from(parent.children).indexOf(el) + 1) + ')';
        }
      }
      parts.unshift(selector);
      el = parent;
    }
    return parts.join(' > ');
  }

  // 요소 설명 생성
  function getElementDescription(el) {
    const tag = el.tagName.toLowerCase();
    const text = (el.textContent || '').trim().slice(0, 40);
    const classes = (el.className || '').toString().trim().split(/\s+/).slice(0, 3).join(' ');
    let desc = `&lt;${tag}&gt;`;
    if (classes) desc += ` .${classes}`;
    if (text) desc += ` "${text}${el.textContent.length > 40 ? '...' : ''}"`;
    return desc;
  }

  function removePopup() {
    const popup = document.getElementById('fb-popup');
    if (popup) popup.remove();
  }

  function updateBadge() {
    if (feedbackMode) {
      badge.innerHTML = `피드백 모드 ON (${feedbacks.length}개) | Ctrl+Shift+C: 복사`;
    } else {
      badge.innerHTML = `F: 피드백 모드 (${feedbacks.length}개)`;
    }
  }

  // 키보드 단축키
  function handleKeydown(e) {
    // F: 모드 토글
    if (e.key === 'f' && !e.ctrlKey && !e.metaKey && !e.altKey &&
        !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
      e.preventDefault();
      toggleMode();
    }

    // Ctrl+Shift+C: 피드백 복사 (Claude Code용)
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'C') {
      e.preventDefault();
      copyFeedbacks();
    }

    // Ctrl+Shift+X: 피드백 초기화
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'X') {
      e.preventDefault();
      clearFeedbacks();
    }

    // Escape: 팝업 닫기
    if (e.key === 'Escape') {
      removePopup();
    }
  }

  // 피드백을 구조화된 텍스트로 복사 (Claude Code에 바로 붙여넣기용)
  function copyFeedbacks() {
    if (feedbacks.length === 0) {
      showToast('피드백이 없습니다');
      return;
    }

    const fileName = document.title || window.location.pathname.split('/').pop() || 'unknown';
    let text = `## 디자인 피드백 — ${fileName}\n\n`;
    text += `피드백 ${feedbacks.length}개. 아래 피드백을 HTML에 반영해주세요.\n\n`;

    feedbacks.forEach((fb, i) => {
      text += `### ${i + 1}. ${fb.comment}\n`;
      text += `- 대상: ${fb.description}\n`;
      text += `- 선택자: \`${fb.selector}\`\n`;
      text += `- 위치: (${fb.position.x}, ${fb.position.y})\n\n`;
    });

    navigator.clipboard.writeText(text).then(() => {
      showToast(`피드백 ${feedbacks.length}개 복사됨 — Claude Code에 붙여넣기하세요`);
    }).catch(() => {
      // 클립보드 실패 시 textarea로 fallback
      const ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      ta.remove();
      showToast(`피드백 ${feedbacks.length}개 복사됨`);
    });
  }

  // 피드백 초기화
  function clearFeedbacks() {
    feedbacks = [];
    highlightedElements.forEach(item => {
      if (item instanceof HTMLElement) item.remove();
      else if (item.element) {
        item.element.style.outline = '';
        item.element.style.outlineOffset = '';
      }
    });
    highlightedElements = [];
    updateBadge();
    showToast('피드백 초기화됨');
  }

  // 토스트 메시지
  function showToast(msg) {
    const toast = document.createElement('div');
    toast.style.cssText = `
      position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%);
      background: #161b22; color: #e6edf3; border: 1px solid #30363d;
      padding: 10px 20px; border-radius: 8px; font-size: 13px; z-index: 100001;
      font-family: -apple-system, sans-serif;
    `;
    toast.textContent = msg;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 2500);
  }

  // DOM 로드 후 실행
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
