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
    
    const canvasWidth = viewportWidth * 2;
    const canvasHeight = viewportHeight * 2.5;
    
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;
    canvas.style.width = canvasWidth + 'px';
    canvas.style.height = canvasHeight + 'px';
    
    const ctx = canvas.getContext('2d');
    
    const nodes = [];
    const centerX = canvasWidth / 2;
    const centerY = canvasHeight / 2;
    const baseRadius = Math.min(canvasWidth, canvasHeight) * 0.25;
    const radiusX = baseRadius * 1.5;
    const radiusY = baseRadius;
    
    const articleIndex = items.findIndex(item => item.getAttribute('data-content-type') === 'article');
    const centerIndex = articleIndex >= 0 ? articleIndex : 0;
    
    items.forEach((item, index) => {
      const rect = item.getBoundingClientRect();
      const itemWidth = rect.width || 200;
      const itemHeight = rect.height || 150;
      
      let x, y;
      
      if (index === centerIndex) {
        x = centerX;
        y = centerY;
      } else {
        const otherItems = items.filter((_, i) => i !== centerIndex);
        const otherIndex = index < centerIndex ? index : index - 1;
        const angle = (otherIndex / otherItems.length) * Math.PI * 2;
        const radiusVariationX = (index % 3) * 0.2;
        const radiusVariationY = (index % 3) * 0.2;
        const radiusXFinal = radiusX * (1 + radiusVariationX);
        const radiusYFinal = radiusY * (1 + radiusVariationY);
        
        const noiseX = (Math.random() - 0.5) * baseRadius * 0.3;
        const noiseY = (Math.random() - 0.5) * baseRadius * 0.3;
        
        x = centerX + Math.cos(angle) * radiusXFinal + noiseX;
        y = centerY + Math.sin(angle) * radiusYFinal + noiseY;
      }
      
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
      const maxDistance = Math.min(canvasWidth, canvasHeight) * 0.4;
      
      for (let i = 0; i < visibleNodes.length; i++) {
        for (let j = i + 1; j < visibleNodes.length; j++) {
          const node1 = visibleNodes[i];
          const node2 = visibleNodes[j];
          
          const dx = node2.x - node1.x;
          const dy = node2.y - node1.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          
          if (distance <= maxDistance) {
            newConnections.push({ from: node1, to: node2 });
          }
        }
      }
      
      return newConnections;
    };

    const getNearestCorners = (node1, node2) => {
      const corners1 = [
        { x: node1.x - node1.width / 2, y: node1.y - node1.height / 2 },
        { x: node1.x + node1.width / 2, y: node1.y - node1.height / 2 },
        { x: node1.x - node1.width / 2, y: node1.y + node1.height / 2 },
        { x: node1.x + node1.width / 2, y: node1.y + node1.height / 2 }
      ];
      
      const corners2 = [
        { x: node2.x - node2.width / 2, y: node2.y - node2.height / 2 },
        { x: node2.x + node2.width / 2, y: node2.y - node2.height / 2 },
        { x: node2.x - node2.width / 2, y: node2.y + node2.height / 2 },
        { x: node2.x + node2.width / 2, y: node2.y + node2.height / 2 }
      ];
      
      let minDistance = Infinity;
      let nearestCorner1 = null;
      let nearestCorner2 = null;
      
      corners1.forEach(corner1 => {
        corners2.forEach(corner2 => {
          const dx = corner2.x - corner1.x;
          const dy = corner2.y - corner1.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          
          if (distance < minDistance) {
            minDistance = distance;
            nearestCorner1 = corner1;
            nearestCorner2 = corner2;
          }
        });
      });
      
      return { from: nearestCorner1, to: nearestCorner2 };
    };

    const drawLines = () => {
      ctx.clearRect(0, 0, canvasWidth, canvasHeight);
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.lineWidth = 1;
      
      const visibleConnections = recalculateConnections();
      
      visibleConnections.forEach(conn => {
        if (!isNodeVisible(conn.from) || !isNodeVisible(conn.to)) return;
        
        const corners = getNearestCorners(conn.from, conn.to);
        
        ctx.beginPath();
        ctx.moveTo(corners.from.x, corners.from.y);
        ctx.lineTo(corners.to.x, corners.to.y);
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
    let velocityX = 0;
    let velocityY = 0;
    let lastTime = 0;
    let lastMoveX = 0;
    let lastMoveY = 0;
    let animationFrameId = null;
    const friction = 0.96;
    const maxX = canvasWidth - viewportWidth;
    const maxY = canvasHeight - viewportHeight;
    
    canvasContainer.style.transform = `translate(${transformX}px, ${transformY}px)`;

    const updateTransform = () => {
      transformX = Math.max(-maxX, Math.min(0, transformX));
      transformY = Math.max(-maxY, Math.min(0, transformY));
      canvasContainer.style.transform = `translate(${transformX}px, ${transformY}px)`;
    };

    const animate = (currentTime) => {
      if (lastTime === 0) {
        lastTime = currentTime;
      }
      const deltaTime = (currentTime - lastTime) / 16;
      lastTime = currentTime;

      if (Math.abs(velocityX) > 0.1 || Math.abs(velocityY) > 0.1) {
        transformX += velocityX * deltaTime;
        transformY += velocityY * deltaTime;
        
        velocityX *= friction;
        velocityY *= friction;
        
        updateTransform();
        animationFrameId = requestAnimationFrame(animate);
      } else {
        velocityX = 0;
        velocityY = 0;
        animationFrameId = null;
      }
    };

    const onMouseDown = (e) => {
      if (e.target.closest('.M_ContentCard-Handle') || e.target.closest('.O_ArticleCard')) {
        return;
      }
      isDragging = true;
      startX = e.clientX;
      startY = e.clientY;
      lastMoveX = e.clientX;
      lastMoveY = e.clientY;
      velocityX = 0;
      velocityY = 0;
      lastTime = 0;
      
      if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
        animationFrameId = null;
      }
      
      canvasContainer.style.cursor = 'grabbing';
    };

    const onMouseMove = (e) => {
      if (!isDragging) return;
      
      const currentTime = performance.now();
      const dx = e.clientX - lastMoveX;
      const dy = e.clientY - lastMoveY;
      
      transformX += dx;
      transformY += dy;
      updateTransform();
      
      const deltaTime = currentTime - (lastTime || currentTime);
      if (deltaTime > 0 && deltaTime < 100) {
        velocityX = dx / deltaTime * 16;
        velocityY = dy / deltaTime * 16;
      }
      
      lastMoveX = e.clientX;
      lastMoveY = e.clientY;
      lastTime = currentTime;
    };

    const onMouseUp = () => {
      if (isDragging) {
        isDragging = false;
        canvasContainer.style.cursor = 'grab';
        
        if (Math.abs(velocityX) > 0.1 || Math.abs(velocityY) > 0.1) {
          lastTime = performance.now();
          animationFrameId = requestAnimationFrame(animate);
        }
      }
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

