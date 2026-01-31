(function () {
  var CONSOLE_SELECTOR = '[data-js-console]';
  var TOGGLE_SELECTOR = '[data-js-console-toggle]';
  var STORAGE_KEY = 'm_console_state';

  function getState() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  }

  function setState(state) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (e) {}
  }

  function pad(n) {
    return (n < 10 ? '0' : '') + n;
  }

  function escapeHtml(s) {
    var div = document.createElement('div');
    div.textContent = s;
    return div.innerHTML;
  }

  function runCommand(cmd) {
    var trimmed = (cmd || '').trim().toLowerCase();
    if (trimmed === '') return '';
    if (trimmed === 'help') {
      return 'Доступные команды:\n  help     — список команд\n  clear    — очистить консоль\n  echo ... — повторить текст\n  about    — о проекте';
    }
    if (trimmed === 'clear') return null;
    if (trimmed === 'about') {
      return 'INSPECTRA — интерактивное медиа про веб. Консоль для кастомных команд.';
    }
    if (trimmed.indexOf('echo ') === 0) {
      return trimmed.slice(5).trim() || '(пусто)';
    }
    return 'Неизвестная команда: ' + escapeHtml(cmd.trim()) + '. Введите help.';
  }

  var PROMPT = '>_ ';

  function updateLineNumbers(container) {
    var linesEl = container.querySelector('[data-js-console-line-numbers]');
    var linesContent = container.querySelector('[data-js-console-lines]');
    var hasInputLine = !!container.querySelector('[data-js-console-input]');
    if (!linesEl || !linesContent) return;
    var count = linesContent.children.length + (hasInputLine ? 1 : 0);
    var html = '';
    for (var i = 1; i <= count; i++) {
      html += '<span class="M_Console-LineNum" data-js-console-ln">' + pad(i) + '</span>';
    }
    linesEl.innerHTML = html || '<span class="M_Console-LineNum" data-js-console-ln>01</span>';
  }

  function setCaretToEnd(el) {
    if (!el || !window.getSelection) return;
    el.focus();
    var range = document.createRange();
    range.selectNodeContents(el);
    range.collapse(false);
    var sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  }

  function getCommandFromInput(inputEl) {
    var text = (inputEl && inputEl.textContent) ? inputEl.textContent : '';
    if (text.indexOf(PROMPT) === 0) return text.slice(PROMPT.length).trim();
    return text.trim();
  }

  function resetInputLine(inputEl) {
    if (!inputEl) return;
    inputEl.textContent = PROMPT;
    setCaretToEnd(inputEl);
  }

  function addLine(container, text, isOutput) {
    var linesEl = container.querySelector('[data-js-console-lines]');
    if (!linesEl) return;
    var div = document.createElement('div');
    div.className = isOutput ? 'M_Console-Line M_Console-Line--output' : 'M_Console-Line M_Console-Line--input';
    div.textContent = text;
    linesEl.appendChild(div);
    var content = container.querySelector('.M_Console-Content');
    if (content) content.scrollTop = content.scrollHeight;
    updateLineNumbers(container);
  }

  function clearLines(container) {
    var linesEl = container.querySelector('[data-js-console-lines]');
    if (linesEl) linesEl.innerHTML = '';
    updateLineNumbers(container);
  }

  function initResize(consoleEl) {
    var right = consoleEl.querySelector('[data-js-console-resize-right]');
    var bottom = consoleEl.querySelector('[data-js-console-resize-bottom]');
    var corner = consoleEl.querySelector('[data-js-console-resize-corner]');

    function startResize(axis, e) {
      e.preventDefault();
      var startX = e.clientX;
      var startY = e.clientY;
      var startW = consoleEl.offsetWidth;
      var startH = consoleEl.offsetHeight;
      var startRight = window.innerWidth - (consoleEl.getBoundingClientRect().left + consoleEl.offsetWidth);
      var startBottom = window.innerHeight - (consoleEl.getBoundingClientRect().top + consoleEl.offsetHeight);

      function move(e) {
        var dx = startX - e.clientX;
        var dy = e.clientY - startY;
        if (axis === 'w' || axis === 'both') {
          var newW = Math.max(280, Math.min(window.innerWidth - 20, startW + dx));
          consoleEl.style.width = newW + 'px';
        }
        if (axis === 'h' || axis === 'both') {
          var newH = Math.max(200, Math.min(window.innerHeight - 20, startH + dy));
          consoleEl.style.height = newH + 'px';
        }
      }
      function stop() {
        document.removeEventListener('mousemove', move);
        document.removeEventListener('mouseup', stop);
        saveSize(consoleEl);
      }
      document.addEventListener('mousemove', move);
      document.addEventListener('mouseup', stop);
    }

    if (right) right.addEventListener('mousedown', function (e) { startResize('w', e); });
    if (bottom) bottom.addEventListener('mousedown', function (e) { startResize('h', e); });
    if (corner) corner.addEventListener('mousedown', function (e) { startResize('both', e); });
  }

  function saveSize(consoleEl) {
    if (consoleEl.classList.contains('is-maximized')) return;
    var state = getState() || {};
    state.width = consoleEl.offsetWidth;
    state.height = consoleEl.offsetHeight;
    setState(state);
  }

  function initDrag(consoleEl) {
    var header = consoleEl.querySelector('[data-js-console-drag]');
    if (!header) return;

    header.addEventListener('mousedown', function (e) {
      if (e.target.closest('.M_Console-Header-Button')) return;
      e.preventDefault();
      var rect = consoleEl.getBoundingClientRect();
      var startX = e.clientX - rect.left;
      var startY = e.clientY - rect.top;
      consoleEl.style.right = '';
      consoleEl.style.bottom = '';

      function move(e) {
        var x = e.clientX - startX;
        var y = e.clientY - startY;
        var maxX = window.innerWidth - 50;
        var maxY = window.innerHeight - 50;
        x = Math.max(0, Math.min(x, maxX));
        y = Math.max(0, Math.min(y, maxY));
        consoleEl.style.left = x + 'px';
        consoleEl.style.top = y + 'px';
        consoleEl.style.right = 'auto';
        consoleEl.style.bottom = 'auto';
      }
      function stop() {
        document.removeEventListener('mousemove', move);
        document.removeEventListener('mouseup', stop);
      }
      document.addEventListener('mousemove', move);
      document.addEventListener('mouseup', stop);
    });
  }

  function init() {
    var toggle = document.querySelector(TOGGLE_SELECTOR);
    var consoleEl = document.querySelector(CONSOLE_SELECTOR);
    if (!toggle || !consoleEl) return;

    var input = consoleEl.querySelector('[data-js-console-input]');
    var closeBtn = consoleEl.querySelector('[data-js-console-close]');
    var maxBtn = consoleEl.querySelector('[data-js-console-maximize]');

    var state = getState();
    if (state && state.width && state.height) {
      consoleEl.style.width = state.width + 'px';
      consoleEl.style.height = state.height + 'px';
    }

    toggle.addEventListener('click', function () {
      consoleEl.style.display = '';
      consoleEl.setAttribute('aria-hidden', 'false');
      if (input) setCaretToEnd(input);
    });

    if (closeBtn) {
      closeBtn.addEventListener('click', function () {
        consoleEl.style.display = 'none';
        consoleEl.setAttribute('aria-hidden', 'true');
        consoleEl.classList.remove('is-maximized');
      });
    }

    if (maxBtn) {
      maxBtn.addEventListener('click', function () {
        consoleEl.classList.toggle('is-maximized');
      });
    }

    if (input) {
      input.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          var cmd = getCommandFromInput(input);
          addLine(consoleEl, '>_ ' + (cmd || ''), false);
          var result = runCommand(cmd);
          if (result === null) {
            clearLines(consoleEl);
          } else if (result !== '') {
            addLine(consoleEl, result, true);
          }
          resetInputLine(input);
          updateLineNumbers(consoleEl);
          var content = consoleEl.querySelector('.M_Console-Content');
          if (content) content.scrollTop = content.scrollHeight;
        }
      });
      input.addEventListener('paste', function (e) {
        e.preventDefault();
        var text = (e.clipboardData || window.clipboardData).getData('text/plain');
        if (text) document.execCommand('insertText', false, text.replace(/[\r\n]+/g, ' '));
      });
    }

    initResize(consoleEl);
    initDrag(consoleEl);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
