(function() {
  window.CanvasDrag = {
    isDragging: false,
    hasDragged: false,
    init: function(canvasContainer, canvasWidth, canvasHeight, viewportWidth, viewportHeight) {
      let isDragging = false;
      let hasDragged = false;
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
      const dragThreshold = 5;
      const maxX = canvasWidth - viewportWidth;
      const maxY = canvasHeight - viewportHeight;

      canvasContainer.style.transform = `translate(${transformX}px, ${transformY}px)`;

      const updateTransform = function() {
        transformX = Math.max(-maxX, Math.min(0, transformX));
        transformY = Math.max(-maxY, Math.min(0, transformY));
        canvasContainer.style.transform = `translate(${transformX}px, ${transformY}px)`;
      };

      const animate = function(currentTime) {
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

      const onMouseDown = function(e) {
        if (e.target.closest('.M_ContentCard-Handle') || 
            e.target.closest('.O_ArticleCard')) {
          return;
        }
        isDragging = true;
        hasDragged = false;
        window.CanvasDrag.isDragging = true;
        window.CanvasDrag.hasDragged = false;
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
        
        const card = e.target.closest('.M_ContentCard');
        if (card) {
          card.dataset.dragStarted = 'true';
        }
      };

      const onMouseMove = function(e) {
        if (!isDragging) return;

        const currentTime = performance.now();
        const dx = e.clientX - lastMoveX;
        const dy = e.clientY - lastMoveY;
        
        const totalDx = e.clientX - startX;
        const totalDy = e.clientY - startY;
        const totalDistance = Math.sqrt(totalDx * totalDx + totalDy * totalDy);
        
        if (totalDistance > dragThreshold) {
          hasDragged = true;
          window.CanvasDrag.hasDragged = true;
        }

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

      const onMouseUp = function(e) {
        if (isDragging) {
          isDragging = false;
          canvasContainer.style.cursor = 'grab';
          
          const wasDragging = window.CanvasDrag.hasDragged;
          window.CanvasDrag.isDragging = false;

          if (hasDragged) {
            setTimeout(function() {
              window.CanvasDrag.hasDragged = false;
            }, 300);
          } else {
            window.CanvasDrag.hasDragged = false;
          }

          if (Math.abs(velocityX) > 0.1 || Math.abs(velocityY) > 0.1) {
            lastTime = performance.now();
            animationFrameId = requestAnimationFrame(animate);
          }
        }
      };

      canvasContainer.addEventListener('mousedown', onMouseDown);
      document.addEventListener('mousemove', onMouseMove);
      document.addEventListener('mouseup', onMouseUp);

      return {
        updateTransform: updateTransform
      };
    }
  };
})();

