(function() {
  const ROOT_SELECTOR = '[data-js-sidebar-mobile]';

  const root = document.querySelector(ROOT_SELECTOR);
  if (!root) return;

  const burgerBtn = root.querySelector('[data-js-sidebar-mobile-burger]');
  const notifBtn = root.querySelector('[data-js-sidebar-mobile-notifications]');
  const overlay = root.querySelector('[data-js-sidebar-mobile-overlay]');

  const navPanel = root.querySelector('[data-js-sidebar-mobile-nav-panel]');
  const notifPanel = root.querySelector('[data-js-sidebar-mobile-notifications-panel]');

  if (!burgerBtn || !notifBtn || !navPanel || !notifPanel) return;

  const setExpanded = (btn, expanded) => {
    if (!btn) return;
    btn.setAttribute('aria-expanded', expanded ? 'true' : 'false');
  };

  const closeAll = () => {
    root.classList.remove('is-open-nav');
    root.classList.remove('is-open-notifications');
    setExpanded(burgerBtn, false);
    setExpanded(notifBtn, false);
  };

  const setArrowOpened = (btn, opened) => {
    if (!btn) return;
    const current = btn.getAttribute('aria-expanded') === 'true';
    if (current === opened) return;
    btn.setAttribute('aria-expanded', opened ? 'true' : 'false');
    const evt = new CustomEvent('arrowbutton:toggle', {
      detail: { opened },
      bubbles: true,
    });
    btn.dispatchEvent(evt);
  };

  const openNav = () => {
    const willOpen = !root.classList.contains('is-open-nav');
    if (!willOpen) return closeAll();

    root.classList.add('is-open-nav');
    root.classList.remove('is-open-notifications');
    setExpanded(burgerBtn, true);
    setExpanded(notifBtn, false);

    const btn0 = navPanel.querySelector('.W_NavigationBar-Item[data-index="0"] .A_ArrowButton');
    const btn1 = navPanel.querySelector('.W_NavigationBar-Item[data-index="1"] .A_ArrowButton');

    const navItems1 = navPanel.querySelector('.W_NavigationItems[data-index="1"]');
    const hasRadioFilters = !!navItems1?.querySelector('.C_RadioButtons');

    setArrowOpened(btn0, true);
    setArrowOpened(btn1, hasRadioFilters);
  };

  const openNotifications = () => {
    const willOpen = !root.classList.contains('is-open-notifications');
    if (!willOpen) return closeAll();

    root.classList.add('is-open-notifications');
    root.classList.remove('is-open-nav');
    setExpanded(notifBtn, true);
    setExpanded(burgerBtn, false);

    const unreadBtn = notifPanel.querySelector('.W_NotificationsBar-Item[data-index="0"] .A_ArrowButton');
    const archiveBtn = notifPanel.querySelector('.W_NotificationsBar-Item[data-index="1"] .A_ArrowButton');
    setArrowOpened(unreadBtn, true);
    setArrowOpened(archiveBtn, false);
  };

  burgerBtn.addEventListener('click', (e) => {
    e.preventDefault();
    openNav();
  });

  notifBtn.addEventListener('click', (e) => {
    e.preventDefault();
    openNotifications();
  });

  overlay?.addEventListener('click', closeAll);

  document.addEventListener('keydown', (e) => {
    if (e.key !== 'Escape') return;
    closeAll();
  });
})();

