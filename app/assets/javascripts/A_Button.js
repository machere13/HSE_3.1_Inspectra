(function(){
  const findGlobalFunction = (functionName) => {
    const parts = (functionName || '').split('.');
    let ctx = window;
    for (let i = 0; i < parts.length; i++) {
      ctx = ctx[parts[i]];
      if (!ctx) return null;
    }
    return typeof ctx === 'function' ? ctx : null;
  };

  const onClick = (e) => {
    const btn = e.target.closest('.A_Button');
    if(!btn) return;
    if(btn.hasAttribute('disabled') || btn.classList.contains('A_Button--Loading')) return;

    const actionName = btn.dataset.action;
    const autoreset = btn.dataset.autoreset !== undefined;
    const actionFn = findGlobalFunction(actionName);

    // если нет кастомного экшна — даём нативному поведению работать (submit и т.п.)
    const typeAttr = (btn.getAttribute('type') || 'button').toLowerCase();
    if(!actionFn){
      if(typeAttr === 'submit') return; // позволяем форме отправиться
      return; // обычная кнопка без action
    }

    // кастомный экшн → берём управление на себя
    e.preventDefault();
    btn.classList.add('A_Button--Loading');
    btn.setAttribute('disabled', 'disabled');
    let maybePromise = null;
    try { maybePromise = actionFn(btn); } catch(err) { console.error(err); }
    const reset = () => { btn.classList.remove('A_Button--Loading'); btn.removeAttribute('disabled'); };
    if(autoreset && maybePromise && typeof maybePromise.finally === 'function'){
      maybePromise.finally(reset);
    } else if(autoreset){
      setTimeout(reset, 600);
    }
  };

  document.addEventListener('click', onClick);
})();


