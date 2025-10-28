(function(){
  const onClick = (e) => {
    const btn = e.target.closest('.A_ArrowButton');
    if(!btn) return;
    const opened = btn.getAttribute('aria-expanded') === 'true';
    btn.setAttribute('aria-expanded', opened ? 'false' : 'true');
    const evt = new CustomEvent('arrowbutton:toggle', { detail: { opened: !opened }, bubbles: true });
    btn.dispatchEvent(evt);
  };

  window.addEventListener('click', onClick);
})();


