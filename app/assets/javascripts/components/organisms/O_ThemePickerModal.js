(function () {
  const MODAL_SELECTOR = '#js-theme-picker-modal';
  const OPEN_SELECTOR = '[data-js-theme-picker-open]';
  const TRANSITION_MS = 280;

  function centerModal(modal) {
    if (!modal) return;
    // позиционируем на центр экрана через явные left/top, чтобы drag не дрался с transform
    const rect = modal.getBoundingClientRect();
    const left = Math.max(0, (window.innerWidth - rect.width) / 2);
    const top = Math.max(0, (window.innerHeight - rect.height) / 2);
    modal.style.left = `${left}px`;
    modal.style.top = `${top}px`;
    modal.style.right = '';
    modal.style.bottom = '';
  }

  function openModal(modal) {
    if (!modal) return;
    modal.style.display = '';
    modal.setAttribute('aria-hidden', 'false');
    requestAnimationFrame(() => {
      centerModal(modal);
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
    if (!modal || modal.dataset.themePickerUiReady === '1') return;
    modal.dataset.themePickerUiReady = '1';

    modal.querySelectorAll('[data-js-theme-picker-close]').forEach((btn) => {
      btn.addEventListener('click', () => closeModal(modal));
    });

    // подключаем drag + resize из W_ControlPanel
    if (window.W_ControlPanel) {
      window.W_ControlPanel.initPanelDrag(modal, {
        ignoreSelector: '.W_ControlPanel-Header-Button'
      });
      window.W_ControlPanel.initPanelResize(modal, {
        minW: 480,
        minH: 360,
        pad: 16
      });
    }
  }

  function init() {
    const modal = document.querySelector(MODAL_SELECTOR);
    if (!modal) return;
    bindModal(modal);

    if (!window.__themePickerDelegated) {
      window.__themePickerDelegated = true;
      document.addEventListener('click', (e) => {
        const t = e.target.closest(OPEN_SELECTOR);
        if (!t) return;
        e.preventDefault();
        openModal(document.querySelector(MODAL_SELECTOR));
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
