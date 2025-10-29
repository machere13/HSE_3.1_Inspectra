(function(){
  function makeDraggable(item){
    const handle = item.querySelector('.M_ContentCard-Handle');
    if (!handle) return;
    const container = item.closest('.PageDay-Content');
    if (!container) return;

    let startX = 0, startY = 0, origLeft = 0, origTop = 0, dragging = false;

    function onMouseMove(e){
      if (!dragging) return;
      e.preventDefault();
      const dx = (e.clientX || 0) - startX;
      const dy = (e.clientY || 0) - startY;
      let newLeft = origLeft + dx;
      let newTop = origTop + dy;
      const contRect = container.getBoundingClientRect();
      const itemRect = item.getBoundingClientRect();
      newLeft = Math.max(0, Math.min(newLeft, contRect.width - itemRect.width));
      newTop = Math.max(0, Math.min(newTop, contRect.height - itemRect.height));
      item.style.left = newLeft + 'px';
      item.style.top = newTop + 'px';
    }

    function onMouseUp(){
      if (!dragging) return;
      dragging = false;
      document.removeEventListener('mousemove', onMouseMove, true);
      document.removeEventListener('mouseup', onMouseUp, true);
      document.body.style.userSelect = '';
    }

    function onMouseDown(e){
      e.preventDefault();
      e.stopPropagation();
      dragging = true;
      const rect = item.getBoundingClientRect();
      const contRect = container.getBoundingClientRect();
      startX = e.clientX;
      startY = e.clientY;
      origLeft = rect.left - contRect.left;
      origTop = rect.top - contRect.top;
      document.addEventListener('mousemove', onMouseMove, true);
      document.addEventListener('mouseup', onMouseUp, true);
      document.body.style.userSelect = 'none';
    }

    handle.addEventListener('mousedown', onMouseDown);
    handle.addEventListener('click', function(e){ e.preventDefault(); e.stopPropagation(); }, true);
  }

  function init(){
    document.querySelectorAll('.PageDay-Content .PageDay-Content-Item').forEach((item)=>{
      if (item.querySelector('.M_ContentCard') || item.querySelector('.O_ArticleCard')){
        item.style.position = item.style.position || 'absolute';
        makeDraggable(item);
      }
    });
  }

  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbo:load', init);
})();


