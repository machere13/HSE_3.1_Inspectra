(function () {
  function handleCheckboxClick(e) {
    const box = e.currentTarget;
    const wrapper = box.closest('.W_Checkbox');
    if (!wrapper) return;
    const btn = wrapper.closest('.A_RadioButton');
    const input = wrapper.querySelector('input[type="checkbox"]');
    if (!input || !btn) return;

    input.checked = !input.checked;
    box.classList.toggle('checked', input.checked);
    btn.classList.toggle('A_RadioButton--Active', input.checked);

    updateVisibility();
  }

  function updateVisibility() {
    const container = document.querySelector('[data-filter-group="content-filters"]');
    if (!container) return;
    
    const activeFilters = [];
    const buttons = document.querySelectorAll('.W_NavigationItems[data-index="1"] .A_RadioButton');
    
    if (buttons) {
      buttons.forEach((btn) => {
        const input = btn.querySelector('input[type="checkbox"]');
        if (input && input.checked) {
          activeFilters.push(input.value);
        }
      });
    }
    
    const items = container.querySelectorAll('[data-content-type]');
    items.forEach((item) => {
      const itemType = item.getAttribute('data-content-type');
      
      if (activeFilters.length === 0) {
        item.style.display = 'block';
      } else if (activeFilters.includes(itemType)) {
        item.style.display = 'block';
      } else {
        item.style.display = 'none';
      }
    });
  }

  function initFilters() {
    document.querySelectorAll('.W_Checkbox .Q_Checkbox').forEach((box) => {
      box.addEventListener('click', handleCheckboxClick);
    });

    document.querySelectorAll('.A_RadioButton').forEach((btn) => {
      const input = btn.querySelector('input[type="checkbox"]');
      const box = btn.querySelector('.W_Checkbox .Q_Checkbox');
      if (input && box) {
        box.classList.toggle('checked', !!input.checked);
        btn.classList.toggle('A_RadioButton--Active', !!input.checked);
      }
    });

    updateVisibility();
  }

  document.addEventListener('DOMContentLoaded', initFilters);
  document.addEventListener('turbo:load', initFilters);
})();

