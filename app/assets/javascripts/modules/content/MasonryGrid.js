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

      const firstGroup = groups[0];
      if (!firstGroup) return;

      setTimeout(function() {
        const masonry = new Masonry(container, {
          itemSelector: '.PageWeek-Content-List-Group',
          columnWidth: firstGroup,
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
                if (loadedCount === images.length && container.masonry) {
                  container.masonry.layout();
                }
              });
            }
          });
          if (loadedCount === images.length && container.masonry) {
            container.masonry.layout();
          }
        }

        let resizeTimeout;
        const resizeHandler = function() {
          clearTimeout(resizeTimeout);
          resizeTimeout = setTimeout(function() {
            if (container.masonry) {
              const firstGroup = container.querySelector('.PageWeek-Content-List-Group');
              if (firstGroup) {
                container.masonry.columnWidth = firstGroup;
                container.masonry.layout();
              }
            }
          }, 250);
        };
        window.addEventListener('resize', resizeHandler);
      }, 100);

      return null;
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
