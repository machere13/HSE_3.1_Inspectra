(function() {
  const NavigationSwitcher = {
    init: function() {
      const switchers = document.querySelectorAll('.M_NavigationSwitcher');
      
      switchers.forEach(function(switcher) {
        switcher.addEventListener('click', function() {
          const currentValue = switcher.dataset.value || 'cobweb';
          const name = switcher.dataset.name;
          const labelElement = switcher.querySelector('.M_NavigationSwitcher-Label');
          
          const newValue = currentValue === 'cobweb' ? 'list' : 'cobweb';
          const newLabel = newValue === 'list' ? 'LIST' : 'COBWEB';
          
          switcher.dataset.value = newValue;
          switcher.classList.toggle('M_NavigationSwitcher--Active', newValue === 'list');
          
          if (labelElement) {
            labelElement.textContent = newLabel;
          }
          
          const changeEvent = new CustomEvent('navigationSwitcher:change', {
            detail: {
              name: name,
              value: newValue,
              switcher: switcher
            },
            bubbles: true
          });
          switcher.dispatchEvent(changeEvent);
        });
      });
    }
  };

  window.NavigationSwitcher = NavigationSwitcher;

  window.DomUtils.ready(function() {
    NavigationSwitcher.init();
  });
  
  window.DomUtils.turboLoad(function() {
    NavigationSwitcher.init();
  });
})();

