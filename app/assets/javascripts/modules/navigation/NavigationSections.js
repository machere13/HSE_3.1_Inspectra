(function() {
  const NavigationSections = {
    findRoot: function(el) {
      return el.closest('.O_Navigation') || document;
    },

    onToggle: function(e) {
      const btn = e.target.closest('.A_ArrowButton');
      if (!btn) return;
      const barItem = btn.closest('.W_NavigationBar-Item');
      if (!barItem) return;
      const idx = barItem.getAttribute('data-index');
      const root = this.findRoot(barItem);
      const content = root.querySelector('.W_NavigationContent');
      if (!content) return;
      const group = content.querySelector('.W_NavigationItems[data-index="' + idx + '"]');
      if (!group) return;
      const opened = btn.getAttribute('aria-expanded') === 'true';
      group.classList.toggle('W_NavigationItems--Hidden', !opened);
    },

    initFromState: function() {
      document.querySelectorAll('.W_NavigationBar-Item').forEach(function(barItem) {
        const btn = barItem.querySelector('.A_ArrowButton');
        if (!btn) return;
        const idx = barItem.getAttribute('data-index');
        const root = NavigationSections.findRoot(barItem);
        const content = root.querySelector('.W_NavigationContent');
        if (!content) return;
        const group = content.querySelector('.W_NavigationItems[data-index="' + idx + '"]');
        if (!group) return;
        const opened = btn.getAttribute('aria-expanded') === 'true';
        group.classList.toggle('W_NavigationItems--Hidden', !opened);
      });
    }
  };

  window.NavigationSections = NavigationSections;

  window.addEventListener('arrowbutton:toggle', function(e) {
    NavigationSections.onToggle(e);
  }, true);

  window.DomUtils.ready(function() {
    NavigationSections.initFromState();
  });
  window.DomUtils.turboLoad(function() {
    NavigationSections.initFromState();
  });
})();

