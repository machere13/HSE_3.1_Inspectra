(function() {
  window.CanvasSetup = {
    init: function(container) {
      const canvas = container.querySelector('.PageWeek-Content-Canvas-Lines');
      if (!canvas) return null;

      const viewportWidth = window.innerWidth;
      const viewportHeight = window.innerHeight;
      const canvasWidth = viewportWidth * 2;
      const canvasHeight = viewportHeight * 2.5;

      canvas.width = canvasWidth;
      canvas.height = canvasHeight;
      canvas.style.width = canvasWidth + 'px';
      canvas.style.height = canvasHeight + 'px';

      return {
        canvas: canvas,
        ctx: canvas.getContext('2d'),
        width: canvasWidth,
        height: canvasHeight,
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight
      };
    }
  };
})();
