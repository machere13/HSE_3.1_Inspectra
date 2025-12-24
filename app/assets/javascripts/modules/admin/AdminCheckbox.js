(function() {
  const AdminCheckbox = {
    init: function() {
      document.querySelectorAll('.admin-checkbox-input').forEach(function(input) {
        if (input.type !== 'checkbox') return;
        
        const label = input.closest('label');
        if (!label) return;
        
        const checkbox = label.querySelector('.Q_Checkbox');
        if (!checkbox) return;

        const updateCheckbox = function() {
          checkbox.classList.toggle('checked', input.checked);
        };

        input.addEventListener('change', updateCheckbox);
        updateCheckbox();
      });
    }
  };

  window.AdminCheckbox = AdminCheckbox;

  window.DomUtils.ready(function() {
    AdminCheckbox.init();
  });
  
  window.DomUtils.turboLoad(function() {
    AdminCheckbox.init();
  });
})();

