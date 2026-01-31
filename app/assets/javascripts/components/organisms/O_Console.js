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
    const text = inputEl?.textContent ?? '';
    if (text.startsWith(PROMPT)) return text.slice(PROMPT.length).trim();
    return text.trim();
  };

  const resetInputLine = (inputEl) => {
    if (!inputEl) return;
    inputEl.textContent = PROMPT;
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

  const initResize = (consoleEl) => {
    const right = consoleEl.querySelector('[data-js-console-resize-right]');
    const bottom = consoleEl.querySelector('[data-js-console-resize-bottom]');
    const corner = consoleEl.querySelector('[data-js-console-resize-corner]');

    const startResize = (axis, e) => {
      e.preventDefault();
      const startX = e.clientX;
      const startY = e.clientY;
      const startW = consoleEl.offsetWidth;
      const startH = consoleEl.offsetHeight;

      const onMove = (ev) => {
        const dx = startX - ev.clientX;
        const dy = ev.clientY - startY;
        if (axis === 'w' || axis === 'both') {
          const newW = Math.max(280, Math.min(window.innerWidth - 20, startW + dx));
          consoleEl.style.width = `${newW}px`;
        }
        if (axis === 'h' || axis === 'both') {
          const newH = Math.max(200, Math.min(window.innerHeight - 20, startH + dy));
          consoleEl.style.height = `${newH}px`;
        }
      };
      const onUp = () => {
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
        saveSize(consoleEl);
        requestAnimationFrame(() => syncLineHeights(consoleEl));
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    };

    right?.addEventListener('mousedown', (e) => startResize('w', e));
    bottom?.addEventListener('mousedown', (e) => startResize('h', e));
    corner?.addEventListener('mousedown', (e) => startResize('both', e));
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

    maxBtn?.addEventListener('click', () => {
      consoleEl.classList.toggle('is-maximized');
    });

    input?.addEventListener('keydown', (e) => {
      if (e.key !== 'Enter') return;
      e.preventDefault();
      const cmd = getCommandFromInput(input);
      addLine(consoleEl, `> ${cmd ?? ''}`, false);
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
