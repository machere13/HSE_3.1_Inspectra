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
      const content = root.querySelector('.W_NotificationItems');
      if (!content) return;
      
      const allItems = content.querySelectorAll('.W_NotificationItems-Item');
      const isNowOpen = e.detail && e.detail.opened !== undefined ? e.detail.opened : btn.getAttribute('aria-expanded') === 'true';
      
      if (isNowOpen) {
        allItems.forEach(function(item) {
          item.classList.add('W_NotificationItems-Item--Hidden');
        });
        
        const selectedItem = content.querySelector('.W_NotificationItems-Item[data-index="' + idx + '"]');
        if (selectedItem) {
          selectedItem.classList.remove('W_NotificationItems-Item--Hidden');
        }
        
        const allBarItems = root.querySelectorAll('.W_NotificationsBar-Item');
        allBarItems.forEach(function(item) {
          const itemBtn = item.querySelector('.A_ArrowButton');
          if (itemBtn) {
            const itemIdx = item.getAttribute('data-index');
            if (itemIdx !== idx) {
              itemBtn.setAttribute('aria-expanded', 'false');
            }
          }
        });
      } else {
        allItems.forEach(function(item) {
          item.classList.add('W_NotificationItems-Item--Hidden');
        });
      }
      
      const hasOpenItems = Array.from(allItems).some(function(item) {
        return !item.classList.contains('W_NotificationItems-Item--Hidden');
      });
      
      if (hasOpenItems) {
        content.classList.remove('W_NotificationItems--Hidden');
      } else {
        content.classList.add('W_NotificationItems--Hidden');
      }
    },

    initFromState: function() {
      document.querySelectorAll('.O_Notifications').forEach(function(root) {
        const content = root.querySelector('.W_NotificationItems');
        if (!content) return;
        
        const allItems = content.querySelectorAll('.W_NotificationItems-Item');
        const allBarItems = root.querySelectorAll('.W_NotificationsBar-Item');
        
        allBarItems.forEach(function(barItem) {
          const btn = barItem.querySelector('.A_ArrowButton');
          if (!btn) return;
          const idx = barItem.getAttribute('data-index');
          const opened = btn.getAttribute('aria-expanded') === 'true';
          const contentItem = content.querySelector('.W_NotificationItems-Item[data-index="' + idx + '"]');
          
          if (contentItem) {
            if (opened) {
              contentItem.classList.remove('W_NotificationItems-Item--Hidden');
              allItems.forEach(function(item) {
                if (item !== contentItem) {
                  item.classList.add('W_NotificationItems-Item--Hidden');
                }
              });
              content.classList.remove('W_NotificationItems--Hidden');
            } else {
              contentItem.classList.add('W_NotificationItems-Item--Hidden');
            }
          }
        });
        
        const hasOpenItems = Array.from(allItems).some(function(item) {
          return !item.classList.contains('W_NotificationItems-Item--Hidden');
        });
        
        if (hasOpenItems) {
          content.classList.remove('W_NotificationItems--Hidden');
        } else {
          content.classList.add('W_NotificationItems--Hidden');
        }
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
