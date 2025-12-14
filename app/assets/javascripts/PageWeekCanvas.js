(function(){
  const initCanvas = () => {
    const container = document.querySelector('.PageWeek-Content');
    const canvasContainer = document.querySelector('.PageWeek-Content-Canvas');
    const canvas = document.querySelector('.PageWeek-Content-Canvas-Lines');
    const itemsContainer = document.querySelector('.PageWeek-Content-Canvas-Items');
    
    if (!container || !canvasContainer || !canvas || !itemsContainer) return;

    const items = Array.from(itemsContainer.querySelectorAll('.PageWeek-Content-Item'));
    if (items.length === 0) return;

    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    
    const canvasWidth = viewportWidth * 3;
    const canvasHeight = viewportHeight * 3;
    
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;
    canvas.style.width = canvasWidth + 'px';
    canvas.style.height = canvasHeight + 'px';
    
    const ctx = canvas.getContext('2d');
    
    const nodes = [];
    const centerX = canvasWidth / 2;
    const centerY = canvasHeight / 2;
    const baseRadius = Math.min(canvasWidth, canvasHeight) * 0.25;
    
    items.forEach((item, index) => {
      const rect = item.getBoundingClientRect();
      const itemWidth = rect.width || 200;
      const itemHeight = rect.height || 150;
      
      const angle = (index / items.length) * Math.PI * 2;
      const radiusVariation = (index % 3) * 0.2;
      const radius = baseRadius * (1 + radiusVariation);
      
      const noiseX = (Math.random() - 0.5) * baseRadius * 0.3;
      const noiseY = (Math.random() - 0.5) * baseRadius * 0.3;
      
      const x = centerX + Math.cos(angle) * radius + noiseX;
      const y = centerY + Math.sin(angle) * radius + noiseY;
      
      nodes.push({
        element: item,
        x: x,
        y: y,
        width: itemWidth,
        height: itemHeight
      });
      
      item.style.left = (x - itemWidth / 2) + 'px';
      item.style.top = (y - itemHeight / 2) + 'px';
      item.style.position = 'absolute';
    });

    const connections = [];
    
    if (nodes.length > 0) {
      const centerNode = nodes[Math.floor(nodes.length / 2)];
      nodes.forEach(node => {
        if (node !== centerNode) {
          connections.push({ from: centerNode, to: node });
        }
      });
    }
    
    for (let i = 0; i < nodes.length; i++) {
      const nextIndex = (i + 1) % nodes.length;
      connections.push({ from: nodes[i], to: nodes[nextIndex] });
      
      if (nodes.length > 3) {
        const skipIndex = (i + Math.floor(nodes.length / 2)) % nodes.length;
        if (skipIndex !== i && skipIndex !== nextIndex) {
          connections.push({ from: nodes[i], to: nodes[skipIndex] });
        }
      }
    }
    
    const uniqueConnections = [];
    const connectionSet = new Set();
    connections.forEach(conn => {
      const key1 = `${conn.from.x},${conn.from.y}-${conn.to.x},${conn.to.y}`;
      const key2 = `${conn.to.x},${conn.to.y}-${conn.from.x},${conn.from.y}`;
      if (!connectionSet.has(key1) && !connectionSet.has(key2)) {
        connectionSet.add(key1);
        uniqueConnections.push(conn);
      }
    });

    const isNodeVisible = (node) => {
      return node.element.style.display !== 'none' && 
             node.element.offsetParent !== null;
    };

    const getVisibleNodes = () => {
      return nodes.filter(isNodeVisible);
    };

    const recalculateConnections = () => {
      const visibleNodes = getVisibleNodes();
      if (visibleNodes.length === 0) return [];
      
      const newConnections = [];
      
      if (visibleNodes.length > 0) {
        const centerNode = visibleNodes[Math.floor(visibleNodes.length / 2)];
        visibleNodes.forEach(node => {
          if (node !== centerNode) {
            newConnections.push({ from: centerNode, to: node });
          }
        });
      }
      
      for (let i = 0; i < visibleNodes.length; i++) {
        const nextIndex = (i + 1) % visibleNodes.length;
        newConnections.push({ from: visibleNodes[i], to: visibleNodes[nextIndex] });
        
        if (visibleNodes.length > 3) {
          const skipIndex = (i + Math.floor(visibleNodes.length / 2)) % visibleNodes.length;
          if (skipIndex !== i && skipIndex !== nextIndex) {
            newConnections.push({ from: visibleNodes[i], to: visibleNodes[skipIndex] });
          }
        }
      }
      
      const connectionSet = new Set();
      const unique = [];
      newConnections.forEach(conn => {
        const key1 = `${conn.from.x},${conn.from.y}-${conn.to.x},${conn.to.y}`;
        const key2 = `${conn.to.x},${conn.to.y}-${conn.from.x},${conn.from.y}`;
        if (!connectionSet.has(key1) && !connectionSet.has(key2)) {
          connectionSet.add(key1);
          unique.push(conn);
        }
      });
      
      return unique;
    };

    const drawLines = () => {
      ctx.clearRect(0, 0, canvasWidth, canvasHeight);
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.lineWidth = 1;
      
      const visibleConnections = recalculateConnections();
      
      visibleConnections.forEach(conn => {
        if (!isNodeVisible(conn.from) || !isNodeVisible(conn.to)) return;
        
        const fromX = conn.from.x;
        const fromY = conn.from.y;
        const toX = conn.to.x;
        const toY = conn.to.y;
        
        ctx.beginPath();
        ctx.moveTo(fromX, fromY);
        ctx.lineTo(toX, toY);
        ctx.stroke();
      });
    };

    const updateNodePositions = () => {
      nodes.forEach(node => {
        if (!isNodeVisible(node)) return;
        const rect = node.element.getBoundingClientRect();
        node.x = node.element.offsetLeft + (rect.width || 200) / 2;
        node.y = node.element.offsetTop + (rect.height || 150) / 2;
        node.width = rect.width || 200;
        node.height = rect.height || 150;
      });
      drawLines();
    };

    setTimeout(() => {
      updateNodePositions();
      drawLines();
    }, 100);

    let isDragging = false;
    let startX = 0;
    let startY = 0;
    let transformX = -(canvasWidth - viewportWidth) / 2;
    let transformY = -(canvasHeight - viewportHeight) / 2;
    canvasContainer.style.transform = `translate(${transformX}px, ${transformY}px)`;

    const onMouseDown = (e) => {
      if (e.target.closest('.M_ContentCard-Handle') || e.target.closest('.O_ArticleCard')) {
        return;
      }
      isDragging = true;
      startX = e.clientX;
      startY = e.clientY;
      canvasContainer.style.cursor = 'grabbing';
    };

    const onMouseMove = (e) => {
      if (!isDragging) return;
      
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;
      
      transformX += dx;
      transformY += dy;
      
      const maxX = canvasWidth - viewportWidth;
      const maxY = canvasHeight - viewportHeight;
      transformX = Math.max(-maxX, Math.min(0, transformX));
      transformY = Math.max(-maxY, Math.min(0, transformY));
      
      canvasContainer.style.transform = `translate(${transformX}px, ${transformY}px)`;
      
      startX = e.clientX;
      startY = e.clientY;
    };

    const onMouseUp = () => {
      isDragging = false;
      canvasContainer.style.cursor = 'grab';
    };

    canvasContainer.addEventListener('mousedown', onMouseDown);
    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);

    const resizeObserver = new ResizeObserver(() => {
      updateNodePositions();
    });
    
    items.forEach(item => {
      resizeObserver.observe(item);
    });

    window.addEventListener('resize', () => {
      updateNodePositions();
    });

    const mutationObserver = new MutationObserver(() => {
      updateNodePositions();
    });
    
    items.forEach(item => {
      mutationObserver.observe(item, {
        attributes: true,
        attributeFilter: ['style']
      });
    });
  };

  document.addEventListener('DOMContentLoaded', initCanvas);
  document.addEventListener('turbo:load', initCanvas);
})();

