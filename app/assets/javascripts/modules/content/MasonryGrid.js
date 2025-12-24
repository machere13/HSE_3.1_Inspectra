(function() {
  const MasonryGrid = {
    init: function(container) {
      if (!container) return;
      
      if (typeof Masonry === 'undefined') {
        console.warn('Masonry library is not loaded');
        return;
      }

      const groups = container.querySelectorAll('.PageWeek-Content-List-Group');
      if (groups.length === 0) return;

      const spacingX12 = getComputedStyle(document.documentElement).getPropertyValue('--spacing-x12');
      let gutter = 48;
      if (spacingX12) {
        const spacingValue = parseInt(spacingX12.trim().replace('px', ''));
        if (!isNaN(spacingValue)) {
          gutter = spacingValue;
        }
      }

      const containerWidth = container.offsetWidth;
      const columnWidth = (containerWidth - 2 * gutter) / 3;

      const masonry = new Masonry(container, {
        itemSelector: '.PageWeek-Content-List-Group',
        columnWidth: columnWidth,
        percentPosition: false,
        gutter: gutter
      });

      container.masonry = masonry;
      container.dataset.masonryInstance = 'true';
      
      setTimeout(function() {
        masonry.layout();
      }, 50);

      const images = container.querySelectorAll('img');
      if (images.length > 0) {
        let loadedCount = 0;
        images.forEach(function(img) {
          if (img.complete) {
            loadedCount++;
          } else {
            img.addEventListener('load', function() {
              loadedCount++;
              if (loadedCount === images.length) {
                masonry.layout();
              }
            });
          }
        });
        if (loadedCount === images.length) {
          masonry.layout();
        }
      }

      let resizeTimeout;
      const resizeHandler = function() {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(function() {
          if (container.masonry) {
            const newContainerWidth = container.offsetWidth;
            const newColumnWidth = (newContainerWidth - 2 * gutter) / 3;
            container.masonry.columnWidth = newColumnWidth;
            container.masonry.layout();
          }
        }, 250);
      };
      window.addEventListener('resize', resizeHandler);

      return masonry;
    },

    update: function(container) {
      if (!container) return;
      
      const groups = container.querySelectorAll('.PageWeek-Content-List-Group');
      if (groups.length === 0) return;

      if (container.masonry) {
        container.masonry.destroy();
        delete container.masonry;
      }
      
      container.dataset.masonryInstance = 'false';

      return this.init(container);
    }
  };

  window.MasonryGrid = MasonryGrid;
})();

