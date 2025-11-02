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

  const validatePassword = (password) => {
    if(!password) return false;
    return password.length >= 8 && password.length <= 64;
  };

  window.submitForm = function(btn){
    const form = btn && btn.closest && btn.closest('form');
    if(!form) return null;
    const emailInput = form.querySelector('input[name="email"]');
    if(emailInput){
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
    }

    const passwordInput = form.querySelector('input[name="password"]');
    const passwordConfirmationInput = form.querySelector('input[name="password_confirmation"]');
    
    if(passwordInput){
      const password = passwordInput.value;
      if(!validatePassword(password)){
        passwordInput.classList.add('A_Input--Error');
        passwordInput.setAttribute('aria-invalid', 'true');
        btn.classList.remove('A_Button--Loading');
        btn.removeAttribute('disabled');
        clearErrorOnInput(passwordInput);
        return null;
      }
    }

    if(passwordConfirmationInput){
      const password = passwordInput ? passwordInput.value : '';
      const passwordConfirmation = passwordConfirmationInput.value;
      if(password !== passwordConfirmation){
        passwordConfirmationInput.classList.add('A_Input--Error');
        passwordConfirmationInput.setAttribute('aria-invalid', 'true');
        btn.classList.remove('A_Button--Loading');
        btn.removeAttribute('disabled');
        clearErrorOnInput(passwordConfirmationInput);
        return null;
      }
    }

    return new Promise((resolve) => setTimeout(resolve, 300));
  };
})();


