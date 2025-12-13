(function(){
  const DOT_SIZE = 3;
  const DOT_SPACING = 40;
  const DOT_STEP = DOT_SIZE + DOT_SPACING;
  const COLOR_ROW_1 = '#4c4c4c';
  const COLOR_ROW_2 = '#282828';

  const isTouchDevice = () => {
    return ("ontouchstart" in window) || (navigator.maxTouchPoints || 0) > 0 || (navigator.msMaxTouchPoints || 0) > 0;
  };

  const prefersReduceMotion = () => {
    try { return window.matchMedia('(prefers-reduced-motion: reduce)').matches; } catch(_) { return false; }
  };

  const lens = (x, y, centerX, centerY, radius, intensity) => {
    const dx = x - centerX;
    const dy = y - centerY;
    const distance = Math.sqrt(dx * dx + dy * dy);
    if (!radius || distance > radius) {
      return { x, y, influence: 0 };
    }
    const ratio = distance / radius;
    const strength = 1 - ratio * ratio;
    const factor = 1 + intensity * strength * strength;
    return {
      x: centerX + dx * factor,
      y: centerY + dy * factor,
      influence: strength
    };
  };

  const createContext = (canvas) => {
    const ctx = canvas.getContext('2d');
    let width = 0;
    let height = 0;
    const adjust = () => {
      const dpr = window.devicePixelRatio || 1;
      const rect = canvas.getBoundingClientRect();
      width = rect.width;
      height = rect.height;
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    adjust();
    const getSize = () => ({ width, height });
    return { ctx, adjust, getSize };
  };

  const render = (ctx, width, height, time, mouseX, mouseY, spacing, state) => {
    ctx.clearRect(0, 0, width, height);
    if (!width || !height) {
      return;
    }

    const hasMouse = mouseX !== undefined && mouseY !== undefined;

    let targetCenterX, targetCenterY, targetRadius, targetIntensity;

    if (hasMouse) {
      targetCenterX = width - mouseX;
      targetCenterY = height - mouseY;
      targetRadius = Math.max(width, height) * 0.35 + Math.sin(time * 0.6) * Math.min(width, height) * 0.03;
      targetIntensity = 0.5 + Math.sin(time * 0.8) * 0.04;
    } else {
      targetCenterX = width * 0.5 + Math.sin(time * 0.25) * width * 0.1;
      targetCenterY = height * 0.5 + Math.cos(time * 0.3) * height * 0.08;
      targetRadius = Math.max(width, height) * 0.15 + Math.sin(time * 0.6) * Math.min(width, height) * 0.03;
      targetIntensity = 0.25 + Math.sin(time * 0.8) * 0.05;
    }

    if (hasMouse) {
      const mouseLerpFactor = 0.15;
      state.currCenterX += (targetCenterX - state.currCenterX) * mouseLerpFactor;
      state.currCenterY += (targetCenterY - state.currCenterY) * mouseLerpFactor;
      state.currRadius += (targetRadius - state.currRadius) * 0.15;
      state.currIntensity += (targetIntensity - state.currIntensity) * 0.15;
    } else {
      const lerpFactor = 0.08;
      state.currCenterX += (targetCenterX - state.currCenterX) * lerpFactor;
      state.currCenterY += (targetCenterY - state.currCenterY) * lerpFactor;
      state.currRadius += (targetRadius - state.currRadius) * lerpFactor;
      state.currIntensity += (targetIntensity - state.currIntensity) * lerpFactor;
    }

    const centerX = state.currCenterX;
    const centerY = state.currCenterY;
    const radius = state.currRadius;
    const intensity = state.currIntensity;
    const secondaryRadius = radius * 0.55;
    const secondaryIntensity = intensity * 1.4;

    const startX = spacing || 0;
    const startY = 0;

    for (let row = 0; row < Math.ceil(height / DOT_STEP) + 2; row++) {
      const baseY = startY + row * DOT_STEP;
      const isEvenRow = row % 2 === 0;
      const color = isEvenRow ? COLOR_ROW_1 : COLOR_ROW_2;

      for (let col = 0; col < Math.ceil(width / DOT_STEP) + 2; col++) {
        const baseX = startX + col * DOT_STEP;

        let rawX = baseX;
        let rawY = baseY;

        const primary = lens(rawX, rawY, centerX, centerY, radius, intensity);
        const secondary = lens(primary.x, primary.y, width - centerX, height - centerY, secondaryRadius, secondaryIntensity);

        const finalX = secondary.x;
        const finalY = secondary.y;

        if (finalX >= -DOT_SIZE && finalX <= width + DOT_SIZE && 
            finalY >= -DOT_SIZE && finalY <= height + DOT_SIZE) {
          ctx.fillStyle = color;
          ctx.beginPath();
          ctx.arc(finalX, finalY, DOT_SIZE / 2, 0, Math.PI * 2);
          ctx.fill();
        }
      }
    }
  };

  const initBackground = (container) => {
    const canvas = container.querySelector('canvas');
    if (!canvas) return;

    const { ctx, adjust, getSize } = createContext(canvas);
    let animationFrame = 0;
    let running = true;
    let mouseX = undefined;
    let mouseY = undefined;
    
    const state = {
      currCenterX: 0,
      currCenterY: 0,
      currRadius: 0,
      currIntensity: 0
    };

    const getSpacing = () => {
      const computedStyle = window.getComputedStyle(container);
      const spacingValue = computedStyle.getPropertyValue('--spacing-x6').trim();
      if (spacingValue) {
        return parseInt(spacingValue) || 0;
      }
      return 24;
    };

    let cachedSpacing = getSpacing();
    let lastWidth = 0;
    let lastHeight = 0;

    const loop = (timestamp) => {
      if (!running) return;

      const { width, height } = getSize();
      
      if (state.currCenterX === 0 && state.currCenterY === 0) {
        state.currCenterX = width * 0.5;
        state.currCenterY = height * 0.5;
        state.currRadius = Math.max(width, height) * 0.15;
        state.currIntensity = 0.25;
      }
      
      if (width !== lastWidth || height !== lastHeight) {
        cachedSpacing = getSpacing();
        lastWidth = width;
        lastHeight = height;
      }
      
      const time = timestamp * 0.001;
      render(ctx, width, height, time, mouseX, mouseY, cachedSpacing, state);
      animationFrame = requestAnimationFrame(loop);
    };

    const updateContainerHeight = () => {
      const parent = container.parentElement;
      if (parent) {
        const spacing = cachedSpacing || getSpacing();
        container.style.height = `${parent.scrollHeight - spacing * 2}px`;
      }
    };

    const handleResize = () => {
      adjust();
      cachedSpacing = getSpacing();
      const { width, height } = getSize();
      lastWidth = width;
      lastHeight = height;
      updateContainerHeight();
    };

    const onMove = (e) => {
      const rect = canvas.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      
      if (x >= 0 && x <= rect.width && y >= 0 && y <= rect.height) {
        mouseX = x;
        mouseY = y;
      } else {
        mouseX = undefined;
        mouseY = undefined;
      }
    };

    const onLeave = () => {
      mouseX = undefined;
      mouseY = undefined;
    };

    handleResize();
    animationFrame = requestAnimationFrame(loop);
    
    window.addEventListener('resize', handleResize);
    window.addEventListener('mousemove', onMove);
    container.addEventListener('mouseleave', onLeave);

    let resizeObserver = null;
    if ('ResizeObserver' in window) {
      resizeObserver = new ResizeObserver(handleResize);
      resizeObserver.observe(container);
      const parent = container.parentElement;
      if (parent) {
        resizeObserver.observe(parent);
      }
    }

    const onVisibilityChange = () => {
      if (!running) return;
      if (document.visibilityState === 'hidden') {
        cancelAnimationFrame(animationFrame);
        animationFrame = 0;
      } else if (!animationFrame) {
        animationFrame = requestAnimationFrame(loop);
      }
    };

    document.addEventListener('visibilitychange', onVisibilityChange);

    const cleanup = () => {
      running = false;
      cancelAnimationFrame(animationFrame);
      window.removeEventListener('resize', handleResize);
      window.removeEventListener('mousemove', onMove);
      window.removeEventListener('beforeunload', cleanup);
      container.removeEventListener('mouseleave', onLeave);
      if (resizeObserver) {
        resizeObserver.disconnect();
      }
      document.removeEventListener('visibilitychange', onVisibilityChange);
      cleanupMap.delete(container);
    };

    cleanupMap.set(container, cleanup);
    window.addEventListener('beforeunload', cleanup);
  };

  const cleanupMap = new WeakMap();

  const boot = () => {
    if (isTouchDevice() || prefersReduceMotion()) return;
    
    document.querySelectorAll('.Q_InspectraBackground').forEach((container) => {
      const existingCleanup = cleanupMap.get(container);
      if (existingCleanup) {
        existingCleanup();
      }
      initBackground(container);
    });
  };

  document.addEventListener('DOMContentLoaded', boot);
  document.addEventListener('turbo:load', boot);
})();

