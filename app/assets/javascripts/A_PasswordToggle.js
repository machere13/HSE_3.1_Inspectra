(function(){
  function onClick(e){
    const btn = e.target.closest('.W_InputPassword-Toggle');
    if(!btn) return;
    const wrap = btn.closest('.W_InputPassword');
    if(!wrap) return;
    const inputId = wrap.getAttribute('data-target');
    const input = inputId ? document.getElementById(inputId) : wrap.querySelector('input');
    if(!input) return;
    const isHidden = input.type === 'password';
    input.type = isHidden ? 'text' : 'password';
    btn.setAttribute('aria-pressed', String(isHidden));
    const icon = btn.querySelector('.W_InputPassword-Icon');
    if(icon){
      icon.dataset.state = isHidden ? 'visible' : 'hidden';
      icon.innerHTML = '';
      const name = isHidden ? 'Q_PasswordVisionIcon' : 'Q_PasswordNonVisionIcon';
      const img = document.createElement('img');
      img.alt = 'toggle';
      img.draggable = false;
      img.width = 16; img.height = 16;
      img.src = '/assets/' + name + '.svg';
      icon.appendChild(img);
    }
  }
  window.addEventListener('click', onClick);
})();


