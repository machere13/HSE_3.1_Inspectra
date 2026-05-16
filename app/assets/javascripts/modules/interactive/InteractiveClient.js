/* eslint-disable no-console */
(() => {
  'use strict';

  document.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-interactive-fetch]');
    if (!btn) return;
    const endpoint = btn.getAttribute('data-endpoint');
    if (!endpoint) return;
    btn.disabled = true;
    fetch(endpoint, { headers: { Accept: 'application/json' } })
      .then((r) => r.json().catch(() => ({})))
      .then((data) => { console.log('[Inspectra] Network response:', data); })
      .catch((err) => { console.error('[Inspectra]', err); })
      .finally(() => { btn.disabled = false; });
  });

  document.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-interactive-race]');
    if (!btn) return;
    const fast = btn.getAttribute('data-fast');
    const slow = btn.getAttribute('data-slow');
    btn.disabled = true;
    Promise.all([
      fetch(fast).then((r) => r.json()).then((d) => { console.log('[Inspectra] race/fast:', d); }),
      fetch(slow).then((r) => r.json()).then((d) => { console.log('[Inspectra] race/slow:', d); }),
    ]).finally(() => { btn.disabled = false; });
  });

  document.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-interactive-cookie-check]');
    if (!btn) return;
    const name = btn.getAttribute('data-cookie-name');
    const value = btn.getAttribute('data-cookie-value');
    const expected = btn.getAttribute('data-expected-token');
    const fb = btn.parentNode && btn.parentNode.querySelector('[data-cookie-feedback]');
    const cookies = document.cookie.split(';').map((s) => s.trim());
    const found = cookies.find((c) => c.indexOf(`${name}=`) === 0);
    if (found && found === `${name}=${value}`) {
      if (fb) fb.textContent = `Кука корректна. Введи ответ: ${expected}`;
    } else if (found) {
      if (fb) fb.textContent = 'Кука есть, но значение не то.';
    } else {
      if (fb) fb.textContent = `Куки с именем "${name}" не нашёл.`;
    }
  });

  document.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-interactive-leak]');
    if (!btn) return;
    if (btn.dataset.leakStarted === '1') return;
    btn.dataset.leakStarted = '1';

    const targetId = parseInt(btn.getAttribute('data-target-id'), 10) || 100;
    const fb = btn.parentNode && btn.parentNode.querySelector('[data-leak-feedback]');
    window.__intervalsLog = window.__intervalsLog || {};
    window.__intervalsLog[targetId] = 0;
    window.__intervalsLog.noise_a = 0;
    window.__intervalsLog.noise_b = 0;

    setInterval(() => { window.__intervalsLog.noise_a += 1; }, 1000);
    setInterval(() => { window.__intervalsLog.noise_b += 1; }, 1500);
    setInterval(() => {
      window.__intervalsLog[targetId] += 1000;
    }, 100);

    let tick = 0;
    const report = setInterval(() => {
      tick += 1;
      console.log(`[Inspectra] window.__intervalsLog (tick ${tick}):`, JSON.parse(JSON.stringify(window.__intervalsLog)));
      if (tick > 10) clearInterval(report);
    }, 1500);

    if (fb) {
      fb.innerHTML = `Запущено 3 интервала. Открой <strong>консоль</strong> — каждые 1.5с печатается состояние <code>window.__intervalsLog</code>. Найди ключ, чьё значение растёт быстрее всех. Это и есть ID.`;
    }
    console.log('[Inspectra] memory leak started. Watch window.__intervalsLog updates.');
  });

  document.querySelectorAll('[data-interactive-console-event]').forEach((root) => {
    const eventName = root.getAttribute('data-event-name') || 'inspectra:secret';
    const token = root.getAttribute('data-token') || 'UNKNOWN';
    let attempts = 0;
    const timer = setInterval(() => {
      window.dispatchEvent(new CustomEvent(eventName, { detail: { token } }));
      attempts += 1;
      if (attempts > 60) clearInterval(timer);
    }, 1500);
    console.log(
      `[Inspectra] CustomEvent dispatcher started. Use:\n  window.addEventListener("${eventName}", e => console.log(e.detail))`
    );
  });

  document.querySelectorAll('[data-interactive-phishing]').forEach((root) => {
    const input = document.querySelector(root.getAttribute('data-target-input'));
    root.querySelectorAll('[data-email-id]').forEach((card) => {
      card.addEventListener('click', () => {
        root.querySelectorAll('[data-email-id]').forEach((c) => {
          c.classList.remove('PageInteractive-Inbox-Item--Selected');
          c.classList.remove('PageInteractive-Email--Selected');
        });
        card.classList.add('PageInteractive-Inbox-Item--Selected');
        if (input) input.value = card.getAttribute('data-email-id');
      });
    });
  });

  document.querySelectorAll('[data-interactive-markers]').forEach((root) => {
    const inputSelector = root.getAttribute('data-target-input');
    const sync = () => {
      const input = document.querySelector(inputSelector);
      if (!input) return;
      const values = [];
      root.querySelectorAll('input[type=checkbox][data-marker-value]').forEach((cb) => {
        if (cb.checked) values.push(cb.getAttribute('data-marker-value'));
      });
      input.value = values.join(',');
    };
    root.addEventListener('change', sync);
    sync();
  });

  document.querySelectorAll('[data-interactive-sandbox]').forEach((root) => {
    const editor = root.querySelector('[data-sandbox-editor]');
    const runBtn = root.querySelector('[data-sandbox-run]');
    const resetBtn = root.querySelector('[data-sandbox-reset]');
    const output = root.querySelector('[data-sandbox-output]');
    const status = root.querySelector('[data-sandbox-status]');
    const expected = (root.getAttribute('data-expected-output') || '').trim();
    const successToken = root.getAttribute('data-success-token') || '';
    const inputSelector = root.getAttribute('data-target-input');
    const initialCode = editor ? editor.value : '';
    const requiredPatternsRaw = root.getAttribute('data-required-patterns') || '';
    const requiredPatterns = requiredPatternsRaw
      ? requiredPatternsRaw.split('|').map((s) => s.trim()).filter(Boolean)
      : [];

    const run = () => {
      if (!editor) return;
      output.textContent = '';
      status.textContent = 'Запускаю в изолированном iframe…';

      const code = editor.value;
      const iframe = document.createElement('iframe');
      iframe.setAttribute('sandbox', 'allow-scripts');
      iframe.style.display = 'none';

      const runnerHtml = `<!DOCTYPE html><html><head></head><body><script>
        (function(){
          const logs = [];
          const orig = { log: console.log, error: console.error };
          console.log = function(){ logs.push(Array.prototype.slice.call(arguments).map(String).join(" ")); orig.log.apply(console, arguments); };
          console.error = function(){ logs.push("ERROR: " + Array.prototype.slice.call(arguments).map(String).join(" ")); orig.error.apply(console, arguments); };
          window.addEventListener("error", function(e){ logs.push("ERROR: " + e.message); parent.postMessage({ kind:"sandbox-done", logs, error: e.message }, "*"); });
          try {
            eval(${JSON.stringify(code)});
            parent.postMessage({ kind:"sandbox-done", logs, error: null }, "*");
          } catch (e) {
            parent.postMessage({ kind:"sandbox-done", logs, error: e.message }, "*");
          }
        })();
      <\/script></body></html>`;
      iframe.srcdoc = runnerHtml;
      document.body.appendChild(iframe);

      let timeoutId = setTimeout(() => {
        finish({ logs: ['ERROR: timeout (3s)'], error: 'timeout' });
      }, 3000);

      const finish = (payload) => {
        if (timeoutId) { clearTimeout(timeoutId); timeoutId = null; }
        window.removeEventListener('message', onMessage);
        if (iframe && iframe.parentNode) iframe.parentNode.removeChild(iframe);
        const rendered = (payload.logs || []).join('\n');
        output.textContent = rendered || '(пусто)';
        if (payload.error) {
          status.textContent = `Ошибка: ${payload.error}`;
          return;
        }
        const trimmed = rendered.trim();
        const outputOk = expected && trimmed === expected;
        const missingPatterns = requiredPatterns.filter((p) => !code.includes(p));

        if (outputOk && missingPatterns.length === 0) {
          status.textContent = '✓ Вывод совпадает + код содержит ожидаемые конструкции. Жми «Проверить».';
          const inp = inputSelector ? document.querySelector(inputSelector) : null;
          if (inp) inp.value = successToken;
        } else if (outputOk && missingPatterns.length > 0) {
          status.textContent = `Вывод верный, но в коде не хватает конструкций: ${missingPatterns.join(', ')}. Не пытайся читерить — почини настоящий код.`;
        } else if (expected) {
          status.textContent = `Вывод не совпадает. Ожидалось: "${expected}".`;
        } else {
          status.textContent = 'Выполнено.';
        }
      };

      const onMessage = (e) => {
        if (!e.data || e.data.kind !== 'sandbox-done') return;
        finish(e.data);
      };
      window.addEventListener('message', onMessage);
    };

    if (runBtn) runBtn.addEventListener('click', run);
    if (resetBtn) resetBtn.addEventListener('click', () => {
      if (editor) editor.value = initialCode;
      output.textContent = '—';
      status.textContent = 'Жду запуска…';
    });
  });

  document.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-interactive-iframe-load]');
    if (!btn) return;
    const holder = document.querySelector(btn.getAttribute('data-iframe-holder'));
    if (!holder) return;
    holder.innerHTML = `<iframe src="${btn.getAttribute('data-iframe-src')}" class="PageInteractive-Iframe" referrerpolicy="no-referrer"></iframe>`;
    btn.disabled = true;
  });
})();
