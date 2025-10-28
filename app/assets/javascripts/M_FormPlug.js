(function(){
  const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/i;

  const isValidEmail = (value) => EMAIL_REGEX.test((value || '').trim());

  const clearErrorOnInput = (input) => {
    const handler = () => {
      input.classList.remove('A_Input--Error');
      input.setAttribute('aria-invalid', 'false');
    };
    input.addEventListener('input', handler, { once: true });
  };

  window.submitForm = function(btn){
    const form = btn && btn.closest && btn.closest('form');
    if(!form) return null;
    const emailInput = form.querySelector('input[name="email"]');
    if(!emailInput) return null;

    const value = emailInput.value;
    const valid = isValidEmail(value);
    if(!valid){
      emailInput.classList.add('A_Input--Error');
      emailInput.setAttribute('aria-invalid', 'true');
      btn.classList.remove('A_Button--Loading');
      btn.removeAttribute('disabled');
      clearErrorOnInput(emailInput);
      return null;
    }

    return new Promise((resolve) => setTimeout(resolve, 300));
  };
})();


