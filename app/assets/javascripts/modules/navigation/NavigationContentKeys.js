(function() {
  const NavigationContentKeys = {
    focusItem: function(group, idx) {
      const items = Array.from(group.querySelectorAll('.M_NavigationItem'));
      if (items.length === 0) return;
      if (idx < 0) idx = items.length - 1;
      if (idx >= items.length) idx = 0;
      items[idx].focus();
      group.dataset.navIndex = String(idx);
    },

    handleGroupKeydown: function(e) {
      const group = e.currentTarget;
      const isFilter = !!group.querySelector('.C_RadioButtons');
      const idx = parseInt(group.dataset.navIndex || '0', 10) || 0;
      const key = e.key;

      const content = group.closest('.W_NavigationContent');
      const left = content ? content.querySelector('.W_NavigationItems[data-index="0"]') : null;
      const right = content ? content.querySelector('.W_NavigationItems[data-index="1"]') : null;
      const rightIsFilter = !!right && !!right.querySelector('.C_RadioButtons');

      if (key === 'ArrowDown') {
        e.preventDefault();
        this.focusItem(group, idx + 1);
      } else if (key === 'ArrowUp') {
        e.preventDefault();
        this.focusItem(group, idx - 1);
      } else if (key === 'ArrowRight') {
        if (group === left && right && !rightIsFilter) {
          e.preventDefault();
          const targetIdx = idx;
          right.dataset.navIndex = String(targetIdx);
          this.focusItem(right, targetIdx);
        }
      } else if (key === 'ArrowLeft') {
        if (group === right && left && !rightIsFilter) {
          e.preventDefault();
          const targetIdx = parseInt(left.dataset.navIndex || '0', 10) || 0;
          this.focusItem(left, targetIdx);
        }
      } else if (key === 'Enter' || key === ' ') {
        const el = document.activeElement;
        if (el && el.classList.contains('M_NavigationItem')) {
          const href = el.getAttribute('data-href');
          if (href) {
            e.preventDefault();
            try {
              window.location.href = href;
            } catch (_) {}
          }
        }
      }
    },

    bind: function() {
      document.querySelectorAll('.W_NavigationItems').forEach(function(group) {
        if (group.querySelectorAll('.M_NavigationItem').length) {
          if (group.dataset.navIndex === undefined) {
            group.dataset.navIndex = '0';
          }
          group.addEventListener('keydown', NavigationContentKeys.handleGroupKeydown.bind(NavigationContentKeys));
        }
      });
    }
  };

  window.NavigationContentKeys = NavigationContentKeys;

  window.DomUtils.ready(function() {
    NavigationContentKeys.bind();
  });
  window.DomUtils.turboLoad(function() {
    NavigationContentKeys.bind();
  });
})();

