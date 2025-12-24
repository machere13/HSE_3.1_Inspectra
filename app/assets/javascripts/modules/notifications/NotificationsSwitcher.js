(function() {
  const NotificationsSwitcher = {
    findRoot: function(el) {
      return el.closest('.O_Notifications') || document;
    },

    onToggle: function(e) {
      const btn = e.target.closest('.A_ArrowButton');
      if (!btn) return;
      const barItem = btn.closest('.W_NotificationsBar-Item');
      if (!barItem) return;
      const idx = barItem.getAttribute('data-index');
      const root = this.findRoot(barItem);
      const content = root.querySelector('.W_NotificationsContent');
      if (!content) return;
      
      const allItems = content.querySelectorAll('.W_NotificationsContent-Item');
      allItems.forEach(function(item) {
        item.classList.add('W_NotificationsContent-Item--Hidden');
      });
      
      const selectedItem = content.querySelector('.W_NotificationsContent-Item[data-index="' + idx + '"]');
      if (selectedItem) {
        selectedItem.classList.remove('W_NotificationsContent-Item--Hidden');
      }
      
      const allBarItems = root.querySelectorAll('.W_NotificationsBar-Item');
      allBarItems.forEach(function(item) {
        const itemBtn = item.querySelector('.A_ArrowButton');
        if (itemBtn) {
          const itemIdx = item.getAttribute('data-index');
          const isActive = itemIdx === idx;
          itemBtn.setAttribute('aria-expanded', isActive ? 'true' : 'false');
        }
      });
    },

    initFromState: function() {
      document.querySelectorAll('.O_Notifications').forEach(function(root) {
        const content = root.querySelector('.W_NotificationsContent');
        if (!content) return;
        
        const allItems = content.querySelectorAll('.W_NotificationsContent-Item');
        const allBarItems = root.querySelectorAll('.W_NotificationsBar-Item');
        
        allBarItems.forEach(function(barItem) {
          const btn = barItem.querySelector('.A_ArrowButton');
          if (!btn) return;
          const idx = barItem.getAttribute('data-index');
          const opened = btn.getAttribute('aria-expanded') === 'true';
          const contentItem = content.querySelector('.W_NotificationsContent-Item[data-index="' + idx + '"]');
          
          if (contentItem) {
            if (opened) {
              contentItem.classList.remove('W_NotificationsContent-Item--Hidden');
              allItems.forEach(function(item) {
                if (item !== contentItem) {
                  item.classList.add('W_NotificationsContent-Item--Hidden');
                }
              });
            } else {
              contentItem.classList.add('W_NotificationsContent-Item--Hidden');
            }
          }
        });
      });
    }
  };

  window.NotificationsSwitcher = NotificationsSwitcher;

  window.addEventListener('arrowbutton:toggle', function(e) {
    const root = NotificationsSwitcher.findRoot(e.target);
    if (root.classList.contains('O_Notifications')) {
      NotificationsSwitcher.onToggle(e);
    }
  }, true);

  window.DomUtils.ready(function() {
    NotificationsSwitcher.initFromState();
  });
  window.DomUtils.turboLoad(function() {
    NotificationsSwitcher.initFromState();
  });
})();

