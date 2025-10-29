(function(){
  function focusItem(group, idx){
    const items = Array.from(group.querySelectorAll('.M_NavigationItem'));
    if(items.length === 0) return;
    if(idx < 0) idx = items.length - 1;
    if(idx >= items.length) idx = 0;
    items[idx].focus();
    group.dataset.navIndex = String(idx);
  }

  function handleGroupKeydown(e){
    const group = e.currentTarget;
    const isFilter = !!group.querySelector('.C_RadioButtons');
    const idx = parseInt(group.dataset.navIndex || '0', 10) || 0;
    const key = e.key;

    const content = group.closest('.W_NavigationContent');
    const left = content?.querySelector('.W_NavigationItems[data-index="0"]');
    const right = content?.querySelector('.W_NavigationItems[data-index="1"]');
    const rightIsFilter = !!right?.querySelector('.C_RadioButtons');

    if(key === 'ArrowDown'){
      e.preventDefault();
      focusItem(group, idx + 1);
    } else if(key === 'ArrowUp'){
      e.preventDefault();
      focusItem(group, idx - 1);
    } else if(key === 'ArrowRight'){
      if(group === left && right && !rightIsFilter){
        e.preventDefault();
        const targetIdx = idx;
        right.dataset.navIndex = String(targetIdx);
        focusItem(right, targetIdx);
      }
    } else if(key === 'ArrowLeft'){
      if(group === right && left && !rightIsFilter){
        e.preventDefault();
        const targetIdx = parseInt(left.dataset.navIndex || '0', 10) || 0;
        focusItem(left, targetIdx);
      }
    } else if(key === 'Enter' || key === ' '){
      const el = document.activeElement;
      if(el && el.classList.contains('M_NavigationItem')){
        const href = el.getAttribute('data-href');
        if(href){ e.preventDefault(); try{ window.location.href = href; } catch(_){} }
      }
    }
  }

  function bind(){
    document.querySelectorAll('.W_NavigationItems').forEach((group) => {
      if(group.querySelectorAll('.M_NavigationItem').length){
        if(group.dataset.navIndex === undefined) group.dataset.navIndex = '0';
        group.addEventListener('keydown', handleGroupKeydown);
      }
    });
  }

  document.addEventListener('DOMContentLoaded', bind);
  document.addEventListener('turbo:load', bind);
})();


