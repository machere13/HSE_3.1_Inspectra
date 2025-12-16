(function() {
  const ContentLayout = {
    randomInt: function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    },

    placeRandom: function() {
      const container = document.querySelector('.PageWeek-Content');
      if (!container) return;
      const canvasContainer = container.querySelector('.PageWeek-Content-Canvas');
      if (canvasContainer) return;
      container.style.position = 'relative';

      const items = Array.from(container.querySelectorAll('.PageWeek-Content-Item'))
        .filter(function(n) {
          return n.querySelector('.M_ContentCard');
        });

      const self = this;
      items.forEach(function(item) {
        if (item.dataset.placed === '1') return;
        item.style.position = 'absolute';

        const rect = container.getBoundingClientRect();
        const itemRect = item.getBoundingClientRect();

        const maxLeft = Math.max(0, rect.width - itemRect.width - 10);
        const maxTop = Math.max(0, rect.height - itemRect.height - 10);

        const left = self.randomInt(0, maxLeft);
        const top = self.randomInt(0, maxTop);

        item.style.left = left + 'px';
        item.style.top = top + 'px';
        item.dataset.placed = '1';
      });
    },

    init: function() {
      this.placeRandom();
    }
  };

  window.ContentLayout = ContentLayout;

  window.DomUtils.ready(function() {
    ContentLayout.init();
  });
  window.DomUtils.turboLoad(function() {
    ContentLayout.init();
  });
})();

