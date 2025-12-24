(function() {
  const initCanvas = function() {
    const container = document.querySelector('.PageWeek-Content');
    const canvasContainer = document.querySelector('.PageWeek-Content-Canvas');
    const itemsContainer = document.querySelector('.PageWeek-Content-Canvas-Items');

    if (!container || !canvasContainer || !itemsContainer) return;
    
    const viewMode = container.getAttribute('data-view-mode') || 'cobweb';
    if (viewMode !== 'cobweb') return;

    const items = Array.from(itemsContainer.querySelectorAll('.PageWeek-Content-Item'));
    if (items.length === 0) return;

    const canvasConfig = window.CanvasSetup.init(container);
    if (!canvasConfig) return;

    const nodes = window.NodePositioner.calculatePositions(
      items,
      canvasConfig.width,
      canvasConfig.height
    );

    const connectionManager = window.ConnectionManager;
    const renderer = window.CanvasRenderer;

    const drawLines = function() {
      const connections = connectionManager.calculateConnections(
        nodes,
        canvasConfig.width,
        canvasConfig.height
      );
      renderer.drawLines(
        canvasConfig.ctx,
        canvasConfig.width,
        canvasConfig.height,
        connections,
        connectionManager
      );
    };

    const updateNodePositions = function() {
      window.NodePositioner.updatePositions(nodes);
      drawLines();
    };

    setTimeout(function() {
      updateNodePositions();
      drawLines();
    }, 100);

    window.CanvasDrag.init(
      canvasContainer,
      canvasConfig.width,
      canvasConfig.height,
      canvasConfig.viewportWidth,
      canvasConfig.viewportHeight
    );

    const resizeObserver = new ResizeObserver(function() {
      updateNodePositions();
    });

    items.forEach(function(item) {
      resizeObserver.observe(item);
    });

    window.addEventListener('resize', function() {
      updateNodePositions();
    });

    const mutationObserver = new MutationObserver(function() {
      updateNodePositions();
    });

    items.forEach(function(item) {
      mutationObserver.observe(item, {
        attributes: true,
        attributeFilter: ['style']
      });
    });
  };

  window.DomUtils.ready(initCanvas);
  window.DomUtils.turboLoad(initCanvas);

  const initViewModeSwitcher = function() {
    const contentContainer = document.querySelector('.PageWeek-Content');
    if (!contentContainer) return;

    document.addEventListener('navigationSwitcher:change', function(e) {
      const value = e.detail.value;
      if (value === 'cobweb' || value === 'list') {
        contentContainer.setAttribute('data-view-mode', value);
        
        if (value === 'cobweb') {
          setTimeout(initCanvas, 100);
        }
      }
    });
  };

  window.DomUtils.ready(initViewModeSwitcher);
  window.DomUtils.turboLoad(initViewModeSwitcher);
})();

