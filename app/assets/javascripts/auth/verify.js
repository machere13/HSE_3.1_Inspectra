function initVerify() {
  const form = document.getElementById('verify-form');
  if (!form) return;

  const inputs = Array.from(document.querySelectorAll('#otp input'));
  const hiddenCode = document.getElementById('code');

  function focusInput(index){ if (index >= 0 && index < inputs.length) inputs[index].focus(); }
  function getCode(){ return inputs.map(i => i.value).join(''); }

  function submitIfReady(){
    const code = getCode();
    if (code.length === 6 && /^\d{6}$/.test(code)) {
      hiddenCode.value = code;
      form.submit();
    }
  }

  inputs.forEach((input, idx) => {
    input.addEventListener('input', (e) => {
      let v = e.target.value.replace(/\D/g, '');
      if (v.length > 1) v = v.slice(-1);
      e.target.value = v;
      if (v && idx < inputs.length - 1) focusInput(idx + 1);
      if (idx === inputs.length - 1 && v) submitIfReady();
    });
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace' && !e.target.value && idx > 0) focusInput(idx - 1);
    });
  });

  const otp = document.getElementById('otp');
  if (otp) {
    otp.addEventListener('paste', (e) => {
      e.preventDefault();
      const text = (e.clipboardData || window.clipboardData).getData('text');
      const digits = (text || '').replace(/\D/g, '').slice(0, 6);
      if (!digits) return;
      for (let i = 0; i < inputs.length; i++) inputs[i].value = digits[i] || '';
      submitIfReady();
    });
  }

  focusInput(0);
}

function initResendCounter() {
  const resendBtn = document.getElementById('resend');
  if (!resendBtn || resendBtn.dataset.left === undefined) return;
  
  let left = parseInt(resendBtn.dataset.left || '0', 10);
  const label = resendBtn.dataset.label || 'Отправить повторно';
  const countdownTpl = resendBtn.dataset.countdownTemplate || 'Отправить повторно (%{seconds})';
  
  if (left > 0) {
    resendBtn.disabled = true;
    const tick = () => {
      left -= 1;
      if (left <= 0) {
        resendBtn.disabled = false;
        resendBtn.textContent = label;
        return;
      }
      resendBtn.textContent = countdownTpl.replace('%{seconds}', String(left));
      setTimeout(tick, 1000);
    };
    setTimeout(tick, 1000);
  }
}

function initVerify() {
  const form = document.getElementById('verify-form');
  if (!form) return;

  const inputs = Array.from(document.querySelectorAll('#otp input'));
  const hiddenCode = document.getElementById('code');

  function focusInput(index){ if (index >= 0 && index < inputs.length) inputs[index].focus(); }
  function getCode(){ return inputs.map(i => i.value).join(''); }

  function submitIfReady(){
    const code = getCode();
    if (code.length === 6 && /^\d{6}$/.test(code)) {
      hiddenCode.value = code;
      form.submit();
    }
  }

  inputs.forEach((input, idx) => {
    input.addEventListener('input', (e) => {
      let v = e.target.value.replace(/\D/g, '');
      if (v.length > 1) v = v.slice(-1);
      e.target.value = v;
      if (v && idx < inputs.length - 1) focusInput(idx + 1);
      if (idx === inputs.length - 1 && v) submitIfReady();
    });
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace' && !e.target.value && idx > 0) focusInput(idx - 1);
    });
  });

  const otp = document.getElementById('otp');
  if (otp) {
    otp.addEventListener('paste', (e) => {
      e.preventDefault();
      const text = (e.clipboardData || window.clipboardData).getData('text');
      const digits = (text || '').replace(/\D/g, '').slice(0, 6);
      if (!digits) return;
      for (let i = 0; i < inputs.length; i++) inputs[i].value = digits[i] || '';
      submitIfReady();
    });
  }

  focusInput(0);
}

document.addEventListener('DOMContentLoaded', function() {
  initVerify();
  initResendCounter();
});
document.addEventListener('turbo:load', function() {
  initVerify();
  initResendCounter();
});
