(() => {
  const CONSOLE_SELECTOR = '[data-js-console]';
  const TOGGLE_SELECTOR = '[data-js-console-toggle]';
  const STORAGE_KEY = 'o_console_state';
  const PROMPT = '>_ ';
  const HISTORY_CAP = 200;

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
  const THEME_ALIASES = {
    dark: 'dark',
    white: 'white',
    'acid-green': 'acid-green',
    neon: 'neon',
    pink: 'pink',
    void: 'void',
    purple: 'purple',
    chrome: 'chrome',
    'ocean-blue': 'ocean-blue',
    vampire: 'vampire',
  };
  const THEME_HINT =
    'theme dark | theme white | theme void | theme purple | theme chrome | theme ocean-blue | theme vampire | theme acid-green | theme neon | theme pink';

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
    if (!theme) return 'dark';
    if (theme === 'white') return 'light';
    return theme;
  };

  const runCommand = (cmd) => {
    const trimmed = (cmd ?? '').trim();
    const lower = trimmed.toLowerCase();
    if (trimmed === '') return '';
    if (lower === 'help') {
      return `Доступные команды:\n  help     — список команд\n  clear    — очистить консоль и историю\n  echo ... — повторить текст\n  theme    — сменить тему (${THEME_HINT})\n  go /path — перейти по пути\n  about    — о проекте\n  ↑ / ↓    — история введённых команд`;
    }
    if (lower === 'clear') return null;
    if (lower === 'about') {
      return 'INSPECTRA — интерактивное медиа про веб. Консоль для кастомных команд.';
    }
    if (lower.startsWith('echo ')) {
      return trimmed.slice(5).trim() || '(пусто)';
    }
    if (lower === 'theme') {
      return `${getThemeName()} | ${THEME_HINT}`;
    }
    if (lower.startsWith('theme ')) {
      const requested = lower.slice(6).trim();
      const resolved = THEME_ALIASES[requested];
      if (!resolved) {
        return `Неизвестная тема: ${escapeHtml(requested)}. ${THEME_HINT}`;
      }
      setTheme(resolved);
      const pretty = resolved === 'dark' ? 'dark' : resolved === 'white' ? 'light' : resolved;
      return `Theme set to ${pretty}`;
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
    const lineEls = linesContent.children;
    const numEls = linesEl.querySelectorAll('[data-js-console-ln]');
    const outputCount = lineEls.length;
    numEls.forEach((numEl) => {
      numEl.style.minHeight = '';
    });
    numEls.forEach((numEl, i) => {
      if (i < outputCount && lineEls[i]) {
        numEl.style.minHeight = `${lineEls[i].offsetHeight}px`;
      }
    });
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
    requestAnimationFrame(() => {
      requestAnimationFrame(() => syncLineHeights(container));
    });
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

  const saveSize = (panelRoot) => {
    if (panelRoot.classList.contains('is-maximized')) return;
    const state = getState() ?? {};
    state.width = panelRoot.offsetWidth;
    state.height = panelRoot.offsetHeight;
    setState(state);
  };

  const exitMaximized = (panelRoot, rect) => {
    if (!panelRoot.classList.contains('is-maximized')) return;
    panelRoot.classList.remove('is-maximized');
    panelRoot.style.left = `${rect.left}px`;
    panelRoot.style.top = `${rect.top}px`;
    panelRoot.style.width = `${rect.width}px`;
    panelRoot.style.height = `${rect.height}px`;
    panelRoot.style.right = '';
    panelRoot.style.bottom = '';
    const btn = panelRoot.querySelector('[data-js-console-maximize]');
    if (btn) btn.setAttribute('aria-label', 'На весь экран');
  };

  const init = () => {
    const state = getState();
    if (state?.theme) applyTheme(state.theme);

    const toggle = document.querySelector(TOGGLE_SELECTOR);
    const innerConsole = document.querySelector(CONSOLE_SELECTOR);
    if (!toggle || !innerConsole) return;

    const panelRoot = innerConsole.closest('.W_ControlPanel') || innerConsole;
    const input = innerConsole.querySelector('[data-js-console-input]');
    const closeBtn = panelRoot.querySelector('[data-js-console-close]');
    const maxBtn = panelRoot.querySelector('[data-js-console-maximize]');

    let commandHistory = [];
    let historyIndex = -1;
    let historyDraft = '';
    let fillingFromHistory = false;

    const pushHistory = (cmd) => {
      const t = (cmd ?? '').trim();
      if (!t) return;
      commandHistory.push(t);
      if (commandHistory.length > HISTORY_CAP) commandHistory.shift();
    };

    let syncLineHeightsRaf = null;
    const scheduleSyncLineHeights = () => {
      if (syncLineHeightsRaf != null) return;
      syncLineHeightsRaf = requestAnimationFrame(() => {
        syncLineHeightsRaf = null;
        syncLineHeights(innerConsole);
      });
    };

    if (typeof ResizeObserver !== 'undefined') {
      const ro = new ResizeObserver(() => scheduleSyncLineHeights());
      ro.observe(innerConsole);
      const linesOut = innerConsole.querySelector('[data-js-console-lines]');
      if (linesOut) ro.observe(linesOut);
    }

    if (state?.width && state?.height) {
      panelRoot.style.width = `${state.width}px`;
      panelRoot.style.height = `${state.height}px`;
    }

    const CONSOLE_TRANSITION_MS = 280;

    toggle.addEventListener('click', () => {
      panelRoot.style.left = '';
      panelRoot.style.top = '';
      panelRoot.style.right = '';
      panelRoot.style.bottom = '';
      panelRoot.style.display = '';
      panelRoot.setAttribute('aria-hidden', 'false');
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          panelRoot.classList.add('is-visible');
          scheduleSyncLineHeights();
        });
      });
      setCaretToEnd(input);
    });

    closeBtn?.addEventListener('click', () => {
      panelRoot.classList.remove('is-visible');
      panelRoot.classList.remove('is-maximized');
      setTimeout(() => {
        panelRoot.style.display = 'none';
        panelRoot.setAttribute('aria-hidden', 'true');
      }, CONSOLE_TRANSITION_MS);
    });

    maxBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      const willBeMax = !panelRoot.classList.contains('is-maximized');
      if (willBeMax) {
        const r = panelRoot.getBoundingClientRect();
        panelRoot.classList.add('is-maximizing');
        panelRoot.style.left = `${r.left}px`;
        panelRoot.style.top = `${r.top}px`;
        panelRoot.style.right = '';
        panelRoot.style.bottom = '';
        panelRoot.style.width = `${r.width}px`;
        panelRoot.style.height = `${r.height}px`;
        void panelRoot.offsetHeight;
        panelRoot.classList.remove('is-maximizing');
        panelRoot.classList.add('is-maximized');
        panelRoot.style.left = '';
        panelRoot.style.top = '';
        panelRoot.style.right = '';
        panelRoot.style.bottom = '';
        panelRoot.style.width = '';
        panelRoot.style.height = '';
        maxBtn?.setAttribute('aria-label', 'Выйти из полноэкранного режима');
        const img = maxBtn?.querySelector('.A_ControlButton-Icon img, .Q_Icon img');
        if (img && maxBtn?.dataset?.iconUrl && maxBtn?.dataset?.iconAltUrl) {
          img.src = maxBtn.dataset.iconAltUrl;
        }
      } else {
        panelRoot.classList.remove('is-maximized');
        maxBtn?.setAttribute('aria-label', 'На весь экран');
        const s = getState();
        if (s?.width && s?.height) {
          panelRoot.style.width = `${s.width}px`;
          panelRoot.style.height = `${s.height}px`;
        }
        panelRoot.style.left = '';
        panelRoot.style.top = '';
        panelRoot.style.right = '';
        panelRoot.style.bottom = '';
        const img = maxBtn?.querySelector('.A_ControlButton-Icon img, .Q_Icon img');
        if (img && maxBtn?.dataset?.iconUrl && maxBtn?.dataset?.iconAltUrl) {
          img.src = maxBtn.dataset.iconUrl;
        }
      }
      scheduleSyncLineHeights();
    });

    input?.addEventListener('input', () => {
      if (fillingFromHistory) return;
      historyIndex = -1;
    });

    input?.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowUp' && commandHistory.length) {
        e.preventDefault();
        if (historyIndex === -1) {
          historyDraft = input.textContent ?? '';
          historyIndex = commandHistory.length - 1;
        } else if (historyIndex > 0) {
          historyIndex -= 1;
        }
        fillingFromHistory = true;
        input.textContent = commandHistory[historyIndex];
        setCaretToEnd(input);
        queueMicrotask(() => {
          fillingFromHistory = false;
        });
        return;
      }
      if (e.key === 'ArrowDown' && historyIndex !== -1) {
        e.preventDefault();
        if (historyIndex < commandHistory.length - 1) {
          historyIndex += 1;
          fillingFromHistory = true;
          input.textContent = commandHistory[historyIndex];
        } else {
          historyIndex = -1;
          fillingFromHistory = true;
          input.textContent = historyDraft;
        }
        setCaretToEnd(input);
        queueMicrotask(() => {
          fillingFromHistory = false;
        });
        return;
      }
      if (e.key !== 'Enter') return;
      e.preventDefault();
      const cmd = getCommandFromInput(input);
      historyIndex = -1;
      historyDraft = '';
      addLine(innerConsole, `${PROMPT}${cmd ?? ''}`, false);
      const result = runCommand(cmd);
      if (result === null) {
        clearLines(innerConsole);
        commandHistory = [];
        scrollToBottom(innerConsole);
      } else if (result !== '') {
        addLine(innerConsole, result, true);
      }
      if ((cmd ?? '').trim() !== '') pushHistory(cmd);
      resetInputLine(input);
    });

    input?.addEventListener('paste', (e) => {
      e.preventDefault();
      const text = (e.clipboardData ?? window.clipboardData)?.getData('text/plain');
      if (text) document.execCommand('insertText', false, text.replace(/\r?\n/g, ' '));
    });

    if (window.W_ControlPanel) {
      window.W_ControlPanel.initPanelResize(panelRoot, {
        minW: 320,
        minH: 200,
        pad: 16,
        onResizeStart: (el, rect) => {
          if (el.classList.contains('is-maximized')) exitMaximized(el, rect);
        },
        onResizeEnd: (el) => {
          saveSize(el);
          scheduleSyncLineHeights();
        },
      });
      window.W_ControlPanel.initPanelDrag(panelRoot, { ignoreSelector: '.W_ControlPanel-Header-Button' });
    }

    window.addEventListener('resize', scheduleSyncLineHeights);
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
