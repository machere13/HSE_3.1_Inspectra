(function() {
  const NavigationRoving = {
    setup: function(container) {
      const items = Array.from(container.querySelectorAll('.M_NavigationItem'));
      if (items.length === 0) return;

      const focusItem = function(idx) {
        if (idx < 0) idx = items.length - 1;
        if (idx >= items.length) idx = 0;
        items[idx].focus();
        container.dataset.navIndex = String(idx);
      };

      if (container.dataset.navIndex === undefined) {
        container.dataset.navIndex = '0';
      }

      container.addEventListener('keydown', function(e) {
        const current = parseInt(container.dataset.navIndex || '0', 10) || 0;
        if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
          e.preventDefault();
          focusItem(current + 1);
        } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
          e.preventDefault();
          focusItem(current - 1);
        } else if (e.key === 'Enter' || e.key === ' ') {
          const el = document.activeElement;
          if (el && el.classList.contains('M_NavigationItem')) {
            const href = el.getAttribute('data-href');
            if (href) {
              window.location.href = href;
            }
          }
        }
      });

      items.forEach(function(el, idx) {
        el.addEventListener('click', function() {
          container.dataset.navIndex = String(idx);
        });
      });
    },

    boot: function() {
      document.querySelectorAll('.W_Navigation').forEach(this.setup.bind(this));
    }
  };

  window.NavigationRoving = NavigationRoving;

  window.DomUtils.ready(function() {
    NavigationRoving.boot();
  });
  window.DomUtils.turboLoad(function() {
    NavigationRoving.boot();
  });
})();

