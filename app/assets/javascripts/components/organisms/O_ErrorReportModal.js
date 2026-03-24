(function () {
  const MODAL_SELECTOR = '#js-error-report-modal';
  const OPEN_SELECTOR = '[data-js-error-report-open]';
  const TRANSITION_MS = 280;

  function openModal(modal, trigger) {
    if (!modal) return;
    const pageUrl = document.getElementById('js-error-report-page-url');
    const statusEl = document.getElementById('js-error-report-status-code');
    const msg = document.getElementById('js-error-report-message');
    if (pageUrl) pageUrl.value = window.location.href;
    if (statusEl) {
      const code = trigger && trigger.getAttribute('data-error-status');
      statusEl.value = code != null && code !== '' ? String(code) : '';
    }
    if (msg) msg.focus();
    modal.style.display = '';
    modal.setAttribute('aria-hidden', 'false');
    requestAnimationFrame(() => {
      requestAnimationFrame(() => modal.classList.add('is-visible'));
    });
  }

  function closeModal(modal) {
    if (!modal) return;
    modal.classList.remove('is-visible');
    setTimeout(() => {
      modal.style.display = 'none';
      modal.setAttribute('aria-hidden', 'true');
    }, TRANSITION_MS);
  }

  function bindModal(modal) {
    if (!modal || modal.dataset.errorReportUiReady === '1') return;
    modal.dataset.errorReportUiReady = '1';

    modal.querySelectorAll('[data-js-error-report-close]').forEach((btn) => {
      btn.addEventListener('click', () => closeModal(modal));
    });

    const msg = modal.querySelector('#js-error-report-message');
    if (
      msg &&
      typeof CSS !== 'undefined' &&
      !CSS.supports('field-sizing', 'content')
    ) {
      const syncHeight = () => {
        msg.style.height = 'auto';
        msg.style.height = `${msg.scrollHeight}px`;
      };
      msg.addEventListener('input', syncHeight);
      syncHeight();
    }
  }

  function init() {
    const modal = document.querySelector(MODAL_SELECTOR);
    if (!modal) return;
    bindModal(modal);

    if (!window.__errorReportDelegated) {
      window.__errorReportDelegated = true;
      document.addEventListener('click', (e) => {
        const t = e.target.closest(OPEN_SELECTOR);
        if (!t) return;
        e.preventDefault();
        openModal(document.querySelector(MODAL_SELECTOR), t);
      });
      document.addEventListener('keydown', (e) => {
        if (e.key !== 'Escape') return;
        const m = document.querySelector(MODAL_SELECTOR);
        if (!m || m.getAttribute('aria-hidden') === 'true') return;
        closeModal(m);
      });
    }
  }

  if (window.DomUtils) {
    window.DomUtils.ready(init);
    window.DomUtils.turboLoad(init);
  } else if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
