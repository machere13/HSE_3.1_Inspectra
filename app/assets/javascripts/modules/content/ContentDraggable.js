(function() {
  const ContentDraggable = {
    makeDraggable: function(item) {
      const handle = item.querySelector('.M_ContentCard-Handle');
      if (!handle) return;
      const container = item.closest('.PageWeek-Content');
      if (!container) return;

      let startX = 0;
      let startY = 0;
      let origLeft = 0;
      let origTop = 0;
      let dragging = false;

      const onMouseMove = function(e) {
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
      };

      const onMouseUp = function() {
        if (!dragging) return;
        dragging = false;
        document.removeEventListener('mousemove', onMouseMove, true);
        document.removeEventListener('mouseup', onMouseUp, true);
        document.body.style.userSelect = '';
      };

      const onMouseDown = function(e) {
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
      };

      handle.addEventListener('mousedown', onMouseDown);
      handle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
      }, true);
    },

    init: function() {
      document.querySelectorAll('.PageWeek-Content .PageWeek-Content-Item').forEach(function(item) {
        if (item.querySelector('.M_ContentCard') || item.querySelector('.O_ArticleCard')) {
          item.style.position = item.style.position || 'absolute';
          this.makeDraggable(item);
        }
      }.bind(this));
    }
  };

  window.ContentDraggable = ContentDraggable;

  window.DomUtils.ready(function() {
    ContentDraggable.init();
  });
  window.DomUtils.turboLoad(function() {
    ContentDraggable.init();
  });
})();

