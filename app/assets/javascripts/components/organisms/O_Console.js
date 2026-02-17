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

  const applyTheme = (name) => {
    const root = document.documentElement;
    if (name && name !== 'dark') {
      root.setAttribute('data-theme', name);
    } else {
      root.removeAttribute('data-theme');
    }
  };

  const THEME_TRANSITION_MS = 550;

  const setTheme = (name) => {
    const state = getState() ?? {};
    state.theme = name === 'dark' || !name ? '' : name;
    setState(state);

    const root = document.documentElement;
    root.classList.add('theme-transitioning');
    applyTheme(state.theme);
    setTimeout(() => root.classList.remove('theme-transitioning'), THEME_TRANSITION_MS);
  };

  const getThemeName = () => {
    const state = getState();
    const theme = state?.theme ?? document.documentElement.getAttribute('data-theme') ?? '';
    return theme === 'white' ? 'light' : 'dark';
  };

  const runCommand = (cmd) => {
    const trimmed = (cmd ?? '').trim();
    const lower = trimmed.toLowerCase();
    if (trimmed === '') return '';
    if (lower === 'help') {
      return 'Доступные команды:\n  help     — список команд\n  clear    — очистить консоль\n  echo ... — повторить текст\n  theme    — сменить тему (theme white / theme dark)\n  go /path — перейти по пути\n  about    — о проекте';
    }
    if (lower === 'clear') return null;
    if (lower === 'about') {
      return 'INSPECTRA — интерактивное медиа про веб. Консоль для кастомных команд.';
    }
    if (lower.startsWith('echo ')) {
      return trimmed.slice(5).trim() || '(пусто)';
    }
    if (lower === 'theme') {
      return `${getThemeName()} | theme white | theme dark`;
    }
    if (lower === 'theme white') {
      setTheme('white');
      return 'Theme set to light';
    }
    if (lower === 'theme dark') {
      setTheme('dark');
      return 'Theme set to dark';
    }
    if (lower.startsWith('go ')) {
      const path = trimmed.slice(3).trim();
      if (path.startsWith('/')) {
        window.location.href = path;
        return `Переход на ${escapeHtml(path)}`;
      }
      return 'Укажите путь с /, например: go /inspectra';
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

  const init = () => {
    const state = getState();
    if (state?.theme) applyTheme(state.theme);

    const toggle = document.querySelector(TOGGLE_SELECTOR);
    const consoleEl = document.querySelector(CONSOLE_SELECTOR);
    if (!toggle || !consoleEl) return;

    const input = consoleEl.querySelector('[data-js-console-input]');
    const closeBtn = consoleEl.querySelector('[data-js-console-close]');
    const maxBtn = consoleEl.querySelector('[data-js-console-maximize]');

    if (state?.width && state?.height) {
      consoleEl.style.width = `${state.width}px`;
      consoleEl.style.height = `${state.height}px`;
    }

    const CONSOLE_TRANSITION_MS = 280;

    toggle.addEventListener('click', () => {
      consoleEl.style.left = '';
      consoleEl.style.top = '';
      consoleEl.style.right = '';
      consoleEl.style.bottom = '';
      consoleEl.style.display = '';
      consoleEl.setAttribute('aria-hidden', 'false');
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          consoleEl.classList.add('is-visible');
        });
      });
      setCaretToEnd(input);
    });

    closeBtn?.addEventListener('click', () => {
      consoleEl.classList.remove('is-visible');
      consoleEl.classList.remove('is-maximized');
      setTimeout(() => {
        consoleEl.style.display = 'none';
        consoleEl.setAttribute('aria-hidden', 'true');
      }, CONSOLE_TRANSITION_MS);
    });

    maxBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      const willBeMax = !consoleEl.classList.contains('is-maximized');
      if (willBeMax) {
        const r = consoleEl.getBoundingClientRect();
        consoleEl.classList.add('is-maximizing');
        consoleEl.style.left = `${r.left}px`;
        consoleEl.style.top = `${r.top}px`;
        consoleEl.style.right = '';
        consoleEl.style.bottom = '';
        consoleEl.style.width = `${r.width}px`;
        consoleEl.style.height = `${r.height}px`;
        void consoleEl.offsetHeight;
        consoleEl.classList.remove('is-maximizing');
        consoleEl.classList.add('is-maximized');
        consoleEl.style.left = '';
        consoleEl.style.top = '';
        consoleEl.style.right = '';
        consoleEl.style.bottom = '';
        consoleEl.style.width = '';
        consoleEl.style.height = '';
        maxBtn?.setAttribute('aria-label', 'Выйти из полноэкранного режима');
        const img = maxBtn?.querySelector('.A_ControlButton-Icon img, .Q_Icon img');
        if (img && maxBtn?.dataset?.iconUrl && maxBtn?.dataset?.iconAltUrl) {
          img.src = maxBtn.dataset.iconAltUrl;
        }
      } else {
        consoleEl.classList.remove('is-maximized');
        maxBtn?.setAttribute('aria-label', 'На весь экран');
        const s = getState();
        if (s?.width && s?.height) {
          consoleEl.style.width = `${s.width}px`;
          consoleEl.style.height = `${s.height}px`;
        }
        consoleEl.style.left = '';
        consoleEl.style.top = '';
        consoleEl.style.right = '';
        consoleEl.style.bottom = '';
        const img = maxBtn?.querySelector('.A_ControlButton-Icon img, .Q_Icon img');
        if (img && maxBtn?.dataset?.iconUrl && maxBtn?.dataset?.iconAltUrl) {
          img.src = maxBtn.dataset.iconUrl;
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

    if (window.W_ControlPanel) {
      window.W_ControlPanel.initPanelResize(consoleEl, {
        minW: 320,
        minH: 200,
        pad: 16,
        onResizeStart: (el, rect) => {
          if (el.classList.contains('is-maximized')) exitMaximized(el, rect);
        },
        onResizeEnd: (el) => {
          saveSize(el);
          requestAnimationFrame(() => syncLineHeights(el));
        }
      });
      window.W_ControlPanel.initPanelDrag(consoleEl, { ignoreSelector: '.O_Console-Header-Button' });
    }
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
