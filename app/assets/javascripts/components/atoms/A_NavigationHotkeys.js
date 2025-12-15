(function(){
  const isTypingContext = (el) => {
    if(!el) return false;
    const tag = el.tagName;
    const editable = el.isContentEditable;
    return editable || tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT';
  };

  const buildMap = () => {
    const map = new Map();
    document.querySelectorAll('.A_NavigationItem[data-hotkey]').forEach((a) => {
      const key = (a.dataset.hotkey || '').toUpperCase();
      const href = a.getAttribute('href');
      if(key && href) map.set(key, href);
    });
    return map;
  };

  let keyToHref = null;

  const onKeyDown = (e) => {
    if(e.defaultPrevented) return;
    if(e.ctrlKey || e.altKey || e.metaKey) return;
    if(isTypingContext(document.activeElement)) return;
    const key = (e.key || '').toUpperCase();
    if(!keyToHref) keyToHref = buildMap();
    const href = keyToHref.get(key);
    if(href){
      e.preventDefault();
      try { window.location.href = href; } catch(_) {}
    }
  };

  const rebuild = () => { keyToHref = buildMap(); };

  window.addEventListener('keydown', onKeyDown);
  window.addEventListener('DOMContentLoaded', rebuild);
  document.addEventListener('turbo:load', rebuild);
})();


