(function() {
  const InteractiveToast = {
    showToast: function(name) {
      const toast = document.querySelector('.M_ToastInteractive');
      if (!toast) return;
      
      toast.setAttribute('data-interactive-name', name || 'Интерактив');
      toast.style.display = 'flex';
      
      setTimeout(function() {
        InteractiveToast.hideToast();
      }, 12000);
    },
    
    hideToast: function() {
      const toast = document.querySelector('.M_ToastInteractive');
      if (!toast) return;
      
      toast.classList.add('M_ToastInteractive--Hiding');
      
      setTimeout(function() {
        toast.style.display = 'none';
        toast.classList.remove('M_ToastInteractive--Hiding');
      }, 300);
    },
    
    openModal: function(name) {
      const modal = document.querySelector('.O_ModalInteractive');
      if (!modal) return;
      
      const textElement = modal.querySelector('.O_ModalInteractive-Modal-Text');
      if (textElement) {
        textElement.textContent = name || modal.getAttribute('data-interactive-name') || 'Интерактив обнаружен!';
      }
      
      modal.style.display = 'flex';
      InteractiveToast.hideToast();
    },
    
    closeModal: function() {
      const modal = document.querySelector('.O_ModalInteractive');
      if (!modal) return;
      
      modal.style.display = 'none';
    },
    
    init: function() {
      const toast = document.querySelector('.M_ToastInteractive');
      if (toast) {
        toast.addEventListener('click', function() {
          const name = toast.getAttribute('data-interactive-name') || 'Интерактив обнаружен!';
          InteractiveToast.openModal(name);
        });
      }
      
      const modal = document.querySelector('.O_ModalInteractive');
      if (modal) {
        modal.addEventListener('click', function(e) {
          if (e.target === modal) {
            InteractiveToast.closeModal();
          }
        });
      }
      
      if (modal) {
        const buttons = modal.querySelectorAll('.A_Button');
        buttons.forEach(function(button, index) {
          button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            if (index === 0) {
              InteractiveToast.closeModal();
            } else if (index === 1) {
              InteractiveToast.closeModal();
              InteractiveToast.openInteractiveSpace();
            }
          });
        });
      }
      
      this.checkForInteractive();
    },
    
    openInteractiveSpace: function() {
      const space = document.querySelector('.SO_InteractiveSpace');
      if (!space) return;
      
      const type = space.getAttribute('data-interactive-type') || 'blind_in_dom';
      
      space.style.display = 'flex';
      
      setTimeout(function() {
        InteractiveToast.bindInteractiveSpaceEvents();
        
        if (type === 'blind_in_dom') {
          InteractiveToast.initBlindInDom();
        }
      }, 100);
    },
    
    closeInteractiveSpace: function() {
      const space = document.querySelector('.SO_InteractiveSpace');
      if (!space) return;
      
      space.style.display = 'none';
      
      const tokenElement = document.querySelector('[data-interactive-token]');
      if (tokenElement) {
        tokenElement.removeAttribute('data-interactive-token');
      }
    },
    
    generateToken: function() {
      if (window.TokenGenerator) {
        return window.TokenGenerator.generate(16);
      }
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      let token = '';
      for (let i = 0; i < 16; i++) {
        token += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      return token;
    },
    
    initBlindInDom: function() {
      const oldTokenElement = document.querySelector('[data-interactive-token]');
      if (oldTokenElement) {
        oldTokenElement.removeAttribute('data-interactive-token');
      }
      
      const token = InteractiveToast.generateToken();
      window.currentInteractiveToken = token;
      
      const interactiveContent = document.querySelector('.SO_InteractiveSpace-Content');
      if (!interactiveContent) return;
      
      const allElements = interactiveContent.querySelectorAll('*');
      if (allElements.length === 0) return;
      
      const randomIndex = Math.floor(Math.random() * allElements.length);
      const randomElement = allElements[randomIndex];
      
      randomElement.setAttribute('data-interactive-token', token);
      
      const tokenInput = document.getElementById('interactive-token-input');
      if (tokenInput) {
        tokenInput.value = '';
      }
    },
    
    bindInteractiveSpaceEvents: function() {
      const space = document.querySelector('.SO_InteractiveSpace');
      if (!space || space.hasAttribute('data-events-bound')) return;
      
      space.setAttribute('data-events-bound', 'true');
      
      const submitButton = document.getElementById('interactive-submit-button');
      const tokenInput = document.getElementById('interactive-token-input');
      const closeButton = document.getElementById('interactive-space-close');
      
      if (submitButton) {
        submitButton.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          InteractiveToast.checkToken();
        });
      }
      
      if (tokenInput) {
        tokenInput.addEventListener('keypress', function(e) {
          if (e.key === 'Enter') {
            e.preventDefault();
            e.stopPropagation();
            InteractiveToast.checkToken();
          }
        });
      }
      
      if (closeButton) {
        closeButton.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          InteractiveToast.closeInteractiveSpace();
        });
      }
    },
    
    checkToken: function() {
      const tokenInput = document.getElementById('interactive-token-input');
      if (!tokenInput) return;
      
      const enteredToken = tokenInput.value.trim();
      const correctToken = window.currentInteractiveToken;
      
      if (!correctToken) {
        if (window.ToastNotification && typeof window.ToastNotification.show === 'function') {
          window.ToastNotification.show('Ошибка: токен не найден', 'error');
        }
        return;
      }
      
      if (enteredToken === correctToken) {
        if (window.ToastNotification && typeof window.ToastNotification.show === 'function') {
          window.ToastNotification.show('Правильно! Интерактив решен', 'success');
        }
        setTimeout(function() {
          InteractiveToast.closeInteractiveSpace();
        }, 500);
      } else {
        if (window.ToastNotification && typeof window.ToastNotification.show === 'function') {
          window.ToastNotification.show('Неправильный токен. Попробуйте еще раз', 'error');
        }
        tokenInput.value = '';
      }
    },
    
    checkForInteractive: function() {
      const interactiveElements = document.querySelectorAll('[data-interactive], .interactive, [data-interactive-name]');
      
      if (interactiveElements.length > 0) {
        const firstInteractive = interactiveElements[0];
        const name = firstInteractive.getAttribute('data-interactive-name') || 
                     firstInteractive.getAttribute('data-interactive') || 
                     'Интерактив';
        
        setTimeout(function() {
          InteractiveToast.showToast(name);
        }, 1000);
      }
    }
  };
  
  window.InteractiveToast = InteractiveToast;
  window.ModalInteractive = {
    close: function() {
      InteractiveToast.closeModal();
    }
  };
  
  window.DomUtils.ready(function() {
    InteractiveToast.init();
  });
  
  window.DomUtils.turboLoad(function() {
    InteractiveToast.init();
  });
})();
