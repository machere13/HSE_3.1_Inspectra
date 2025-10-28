(function(){
  function findRoot(el){
    return el.closest('.O_Navigation') || document;
  }

  function onToggle(e){
    const btn = e.target.closest('.A_ArrowButton');
    if(!btn) return;
    const barItem = btn.closest('.W_NavigationBar-Item');
    if(!barItem) return;
    const idx = barItem.getAttribute('data-index');
    const root = findRoot(barItem);
    const content = root.querySelector('.W_NavigationContent');
    if(!content) return;
    const group = content.querySelector('.W_NavigationItems[data-index="' + idx + '"]');
    if(!group) return;
    const opened = btn.getAttribute('aria-expanded') === 'true';
    group.classList.toggle('W_NavigationItems--Hidden', !opened);
  }

  function initFromState(){
    document.querySelectorAll('.W_NavigationBar-Item').forEach((barItem) => {
      const btn = barItem.querySelector('.A_ArrowButton');
      if(!btn) return;
      const idx = barItem.getAttribute('data-index');
      const root = findRoot(barItem);
      const content = root.querySelector('.W_NavigationContent');
      if(!content) return;
      const group = content.querySelector('.W_NavigationItems[data-index="' + idx + '"]');
      if(!group) return;
      const opened = btn.getAttribute('aria-expanded') === 'true';
      group.classList.toggle('W_NavigationItems--Hidden', !opened);
    });
  }

  window.addEventListener('arrowbutton:toggle', onToggle, true);
  window.addEventListener('DOMContentLoaded', initFromState);
  document.addEventListener('turbo:load', initFromState);
})();


