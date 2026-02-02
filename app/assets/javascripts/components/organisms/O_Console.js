(() => {
  const CONSOLE_SELECTOR = '[data-js-console]';
  const TOGGLE_SELECTOR = '[data-js-console-toggle]';
  const STORAGE_KEY = 'o_console_state';
  const PROMPT = '>_ ';

  const getState = () => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch {
      return null;
    }
  };

  const setState = (state) => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch {}
  };

  const pad = (n) => (n < 10 ? '0' : '') + n;

  const escapeHtml = (s) => {
    const div = document.createElement('div');
    div.textContent = s;
    return div.innerHTML;
  };

  const runCommand = (cmd) => {
    const trimmed = (cmd ?? '').trim().toLowerCase();
    if (trimmed === '') return '';
    if (trimmed === 'help') {
      return 'Доступные команды:\n  help     — список команд\n  clear    — очистить консоль\n  echo ... — повторить текст\n  about    — о проекте';
    }
    if (trimmed === 'clear') return null;
    if (trimmed === 'about') {
      return 'INSPECTRA — интерактивное медиа про веб. Консоль для кастомных команд.';
    }
    if (trimmed.startsWith('echo ')) {
      return trimmed.slice(5).trim() || '(пусто)';
    }
    return `Unknown command: ${escapeHtml(cmd.trim())}. Введите help.`;
  };

  const syncLineHeights = (container) => {
    const linesEl = container.querySelector('[data-js-console-line-numbers]');
    const linesContent = container.querySelector('[data-js-console-lines]');
    if (!linesEl || !linesContent) return;
    const outputCount = linesContent.children.length;
    for (let i = 0; i < outputCount; i++) {
      const lineEl = linesContent.children[i];
      const numEl = linesEl.children[i];
      if (lineEl && numEl) numEl.style.minHeight = `${lineEl.offsetHeight}px`;
    }
    const lastNum = linesEl.children[outputCount];
    if (lastNum) lastNum.style.minHeight = '';
  };

  const updateLineNumbers = (container) => {
    const linesEl = container.querySelector('[data-js-console-line-numbers]');
    const linesContent = container.querySelector('[data-js-console-lines]');
    if (!linesEl || !linesContent) return;
    const outputCount = linesContent.children.length;
    const count = outputCount + 1;
    const parts = [];
    for (let i = 0; i < count; i++) {
      const isError = i < outputCount && linesContent.children[i].classList.contains('O_Console-Line--error');
      const cls = isError ? 'O_Console-LineNum text-code O_Console-LineNum--error' : 'O_Console-LineNum text-code';
      parts.push(`<span class="${cls}" data-js-console-ln>${pad(i + 1)}</span>`);
    }
    linesEl.innerHTML = parts.length ? parts.join('') : '<span class="O_Console-LineNum text-code" data-js-console-ln>01</span>';
    requestAnimationFrame(() => syncLineHeights(container));
  };

  const setCaretToEnd = (el) => {
    if (!el?.focus || !window.getSelection) return;
    el.focus();
    const range = document.createRange();
    range.selectNodeContents(el);
    range.collapse(false);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  };

  const getCommandFromInput = (inputEl) => {
    return (inputEl?.textContent ?? '').trim();
  };

  const resetInputLine = (inputEl) => {
    if (!inputEl) return;
    inputEl.textContent = '';
    setCaretToEnd(inputEl);
  };

  const scrollToBottom = (container) => {
    const scrollEl = container.querySelector('[data-js-console-scroll]');
    if (scrollEl) scrollEl.scrollTop = scrollEl.scrollHeight;
  };

  const addLine = (container, text, isOutput) => {
    const linesEl = container.querySelector('[data-js-console-lines]');
    if (!linesEl) return;
    const div = document.createElement('div');
    let className = isOutput ? 'O_Console-Line O_Console-Line--output' : 'O_Console-Line O_Console-Line--input';
    if (isOutput && text.startsWith('Unknown command:')) className += ' O_Console-Line--error';
    div.className = className;
    div.textContent = text;
    linesEl.appendChild(div);
    updateLineNumbers(container);
    scrollToBottom(container);
  };

  const clearLines = (container) => {
    const linesEl = container.querySelector('[data-js-console-lines]');
    if (linesEl) linesEl.innerHTML = '';
    updateLineNumbers(container);
  };

  const saveSize = (consoleEl) => {
    if (consoleEl.classList.contains('is-maximized')) return;
    const state = getState() ?? {};
    state.width = consoleEl.offsetWidth;
    state.height = consoleEl.offsetHeight;
    setState(state);
  };

  const RESIZE = {
    MIN_W: 320,
    MIN_H: 200,
    PAD: 16,
  };

  const exitMaximized = (consoleEl, rect) => {
    if (!consoleEl.classList.contains('is-maximized')) return;
    consoleEl.classList.remove('is-maximized');
    consoleEl.style.left = `${rect.left}px`;
    consoleEl.style.top = `${rect.top}px`;
    consoleEl.style.width = `${rect.width}px`;
    consoleEl.style.height = `${rect.height}px`;
    consoleEl.style.right = '';
    consoleEl.style.bottom = '';
    const btn = consoleEl.querySelector('[data-js-console-maximize]');
    if (btn) btn.setAttribute('aria-label', 'На весь экран');
  };

  const initResize = (consoleEl) => {
    const bind = (selector, edges) => {
      const el = consoleEl.querySelector(selector);
      if (!el) return;
      el.addEventListener('mousedown', (e) => {
        e.preventDefault();

        const rect = consoleEl.getBoundingClientRect();
        if (consoleEl.classList.contains('is-maximized')) {
          exitMaximized(consoleEl, rect);
        }

        const start = {
          left: rect.left,
          top: rect.top,
          right: rect.left + rect.width,
          bottom: rect.top + rect.height,
          x: e.clientX,
          y: e.clientY,
        };

        consoleEl.style.right = '';
        consoleEl.style.bottom = '';

        const onMove = (ev) => {
          const dx = ev.clientX - start.x;
          const dy = ev.clientY - start.y;

          let left = edges.w ? start.left + dx : start.left;
          let right = edges.e ? start.right + dx : start.right;
          let top = edges.n ? start.top + dy : start.top;
          let bottom = edges.s ? start.bottom + dy : start.bottom;

          const vw = window.innerWidth - RESIZE.PAD;
          const vh = window.innerHeight - RESIZE.PAD;

          if (right - left < RESIZE.MIN_W) {
            if (edges.w) left = right - RESIZE.MIN_W;
            else right = left + RESIZE.MIN_W;
          }
          if (bottom - top < RESIZE.MIN_H) {
            if (edges.n) top = bottom - RESIZE.MIN_H;
            else bottom = top + RESIZE.MIN_H;
          }

          left = Math.max(0, Math.min(left, vw - RESIZE.MIN_W));
          right = Math.max(left + RESIZE.MIN_W, Math.min(right, vw));
          top = Math.max(0, Math.min(top, vh - RESIZE.MIN_H));
          bottom = Math.max(top + RESIZE.MIN_H, Math.min(bottom, vh));

          consoleEl.style.left = `${left}px`;
          consoleEl.style.top = `${top}px`;
          consoleEl.style.width = `${right - left}px`;
          consoleEl.style.height = `${bottom - top}px`;
        };

        const onUp = () => {
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
          saveSize(consoleEl);
          requestAnimationFrame(() => syncLineHeights(consoleEl));
        };

        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    };

    bind('[data-js-console-resize-left]', { w: true });
    bind('[data-js-console-resize-right]', { e: true });
    bind('[data-js-console-resize-top]', { n: true });
    bind('[data-js-console-resize-bottom]', { s: true });
    bind('[data-js-console-resize-nw]', { n: true, w: true });
    bind('[data-js-console-resize-ne]', { n: true, e: true });
    bind('[data-js-console-resize-sw]', { s: true, w: true });
    bind('[data-js-console-resize-se]', { s: true, e: true });
  };

  const initDrag = (consoleEl) => {
    const header = consoleEl.querySelector('[data-js-console-drag]');
    if (!header) return;

    header.addEventListener('mousedown', (e) => {
      if (e.target.closest('.O_Console-Header-Button')) return;
      e.preventDefault();
      const rect = consoleEl.getBoundingClientRect();
      const startX = e.clientX - rect.left;
      const startY = e.clientY - rect.top;
      consoleEl.style.right = '';
      consoleEl.style.bottom = '';

      const onMove = (ev) => {
        const x = Math.max(0, Math.min(ev.clientX - startX, window.innerWidth - 50));
        const y = Math.max(0, Math.min(ev.clientY - startY, window.innerHeight - 50));
        consoleEl.style.left = `${x}px`;
        consoleEl.style.top = `${y}px`;
        consoleEl.style.right = 'auto';
        consoleEl.style.bottom = 'auto';
      };
      const onUp = () => {
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });
  };

  const init = () => {
    const toggle = document.querySelector(TOGGLE_SELECTOR);
    const consoleEl = document.querySelector(CONSOLE_SELECTOR);
    if (!toggle || !consoleEl) return;

    const input = consoleEl.querySelector('[data-js-console-input]');
    const closeBtn = consoleEl.querySelector('[data-js-console-close]');
    const maxBtn = consoleEl.querySelector('[data-js-console-maximize]');

    const state = getState();
    if (state?.width && state?.height) {
      consoleEl.style.width = `${state.width}px`;
      consoleEl.style.height = `${state.height}px`;
    }

    toggle.addEventListener('click', () => {
      consoleEl.style.display = '';
      consoleEl.setAttribute('aria-hidden', 'false');
      setCaretToEnd(input);
    });

    closeBtn?.addEventListener('click', () => {
      consoleEl.style.display = 'none';
      consoleEl.setAttribute('aria-hidden', 'true');
      consoleEl.classList.remove('is-maximized');
    });

    maxBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      const isMax = consoleEl.classList.toggle('is-maximized');
      maxBtn?.setAttribute('aria-label', isMax ? 'Выйти из полноэкранного режима' : 'На весь экран');
      if (isMax) {
        consoleEl.style.left = '';
        consoleEl.style.top = '';
        consoleEl.style.right = '';
        consoleEl.style.bottom = '';
        consoleEl.style.width = '';
        consoleEl.style.height = '';
      } else {
        const s = getState();
        if (s?.width && s?.height) {
          consoleEl.style.width = `${s.width}px`;
          consoleEl.style.height = `${s.height}px`;
        }
      }
    });

    input?.addEventListener('keydown', (e) => {
      if (e.key !== 'Enter') return;
      e.preventDefault();
      const cmd = getCommandFromInput(input);
      addLine(consoleEl, `${PROMPT}${cmd ?? ''}`, false);
      const result = runCommand(cmd);
      if (result === null) {
        clearLines(consoleEl);
      } else if (result !== '') {
        addLine(consoleEl, result, true);
      }
      resetInputLine(input);
      updateLineNumbers(consoleEl);
      scrollToBottom(consoleEl);
    });

    input?.addEventListener('paste', (e) => {
      e.preventDefault();
      const text = (e.clipboardData ?? window.clipboardData)?.getData('text/plain');
      if (text) document.execCommand('insertText', false, text.replace(/\r?\n/g, ' '));
    });

    initResize(consoleEl);
    initDrag(consoleEl);
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
