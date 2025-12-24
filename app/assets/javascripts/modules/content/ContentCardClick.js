(function() {
  const ContentCardClick = {
    init: function() {
      document.addEventListener('click', function(e) {
        const card = e.target.closest('.M_ContentCard');
        if (!card) return;
        
        if (window.CanvasDrag && window.CanvasDrag.hasDragged) {
          e.preventDefault();
          e.stopPropagation();
          return;
        }
        
        const url = card.dataset.url;
        if (url) {
          e.preventDefault();
          window.location.href = url;
        }
      }, true);
    }
  };

  window.ContentCardClick = ContentCardClick;

  window.DomUtils.ready(function() {
    ContentCardClick.init();
  });
  
  window.DomUtils.turboLoad(function() {
    ContentCardClick.init();
  });
})();

