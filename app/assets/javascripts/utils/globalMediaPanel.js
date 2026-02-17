(() => {
  const DEFAULT_TRANSITION_MS = 280;

  const showGlobalContainer = (container, options) => {
    if (!container) return;
    container.style.display = '';
    container.setAttribute('aria-hidden', 'false');
    if (options?.visibleKey) {
      try { sessionStorage.setItem(options.visibleKey, '1'); } catch {}
    }
    requestAnimationFrame(() => {
      requestAnimationFrame(() => container.classList.add('is-visible'));
    });
  };

  const hideGlobalContainer = (container, options) => {
    if (!container) return;
    container.classList.remove('is-visible');
    const transitionMs = options?.transitionMs ?? DEFAULT_TRANSITION_MS;
    setTimeout(() => {
      container.style.display = 'none';
      container.setAttribute('aria-hidden', 'true');
      if (options?.visibleKey) try { sessionStorage.removeItem(options.visibleKey); } catch {}
    }, transitionMs);
  };

  const isGlobalVisible = (visibleKey) => {
    try { return sessionStorage.getItem(visibleKey) === '1'; } catch { return false; }
  };

  window.GlobalMediaPanel = { showGlobalContainer, hideGlobalContainer, isGlobalVisible };
})();
