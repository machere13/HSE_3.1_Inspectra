(function() {
  const ContentFilter = {
    handleCheckboxClick: function(e) {
      const box = e.currentTarget;
      const wrapper = box.closest('.W_Checkbox');
      if (!wrapper) return;
      const btn = wrapper.closest('.A_RadioButton');
      const input = wrapper.querySelector('input[type="checkbox"]');
      if (!input || !btn) return;

      input.checked = !input.checked;
      box.classList.toggle('checked', input.checked);
      btn.classList.toggle('A_RadioButton--Active', input.checked);

      this.updateVisibility();
    },

    updateVisibility: function() {
      const container = document.querySelector('[data-filter-group="content-filters"]');
      if (!container) return;

      const activeFilters = [];
      const buttons = document.querySelectorAll('.W_NavigationItems[data-index="1"] .A_RadioButton');

      if (buttons) {
        buttons.forEach(function(btn) {
          const input = btn.querySelector('input[type="checkbox"]');
          if (input && input.checked) {
            activeFilters.push(input.value);
          }
        });
      }

      const items = container.querySelectorAll('[data-content-type]');
      items.forEach(function(item) {
        const itemType = item.getAttribute('data-content-type');

        if (activeFilters.length === 0) {
          item.style.display = '';
        } else if (activeFilters.includes(itemType)) {
          item.style.display = '';
        } else {
          item.style.display = 'none';
        }
      });
      
      const listContainer = container.querySelector('.PageWeek-Content-List');
      if (listContainer && window.MasonryGrid && container.getAttribute('data-view-mode') === 'list' && typeof Masonry !== 'undefined') {
        setTimeout(function() {
          if (listContainer.masonry) {
            listContainer.masonry.layout();
          } else {
            window.MasonryGrid.update(listContainer);
          }
        }, 100);
      }
    },

    initFilters: function() {
      document.querySelectorAll('.W_Checkbox .Q_Checkbox').forEach(function(box) {
        box.addEventListener('click', this.handleCheckboxClick.bind(this));
      }.bind(this));

      document.querySelectorAll('.A_RadioButton').forEach(function(btn) {
        const input = btn.querySelector('input[type="checkbox"]');
        const box = btn.querySelector('.W_Checkbox .Q_Checkbox');
        if (input && box) {
          box.classList.toggle('checked', !!input.checked);
          btn.classList.toggle('A_RadioButton--Active', !!input.checked);
        }
      });

      this.updateVisibility();
    }
  };

  window.ContentFilter = ContentFilter;

  window.DomUtils.ready(function() {
    ContentFilter.initFilters();
  });
  window.DomUtils.turboLoad(function() {
    ContentFilter.initFilters();
  });
})();

