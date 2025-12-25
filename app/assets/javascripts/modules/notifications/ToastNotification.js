(function() {
  const ToastNotification = {
    show: function(text, type) {
      const toast = document.createElement('div');
      let className = 'M_ToastNotification';
      if (type === 'error') {
        className += ' M_ToastNotification--Error';
      } else if (type === 'success') {
        className += ' M_ToastNotification--Success';
      }
      toast.className = className;
      toast.innerHTML = '<span class="M_ToastNotification-Text text-p-1-mono">' + text + '</span>';
      
      document.body.appendChild(toast);
      
      requestAnimationFrame(function() {
        toast.style.opacity = '1';
      });
      
      setTimeout(function() {
        ToastNotification.hide(toast);
      }, 3000);
      
      return toast;
    },
    
    hide: function(toast) {
      if (!toast) return;
      
      toast.classList.add('M_ToastNotification--Hiding');
      
      setTimeout(function() {
        if (toast.parentNode) {
          toast.parentNode.removeChild(toast);
        }
      }, 300);
    },
    
    init: function() {
      const existingToasts = document.querySelectorAll('.M_ToastNotification:not([data-toast-initialized])');
      existingToasts.forEach(function(toast) {
        toast.setAttribute('data-toast-initialized', 'true');
        setTimeout(function() {
          ToastNotification.hide(toast);
        }, 3000);
      });
    }
  };
  
  window.ToastNotification = ToastNotification;
  
  window.DomUtils.ready(function() {
    ToastNotification.init();
  });
  
  window.DomUtils.turboLoad(function() {
    ToastNotification.init();
  });
})();

