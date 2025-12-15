(function(){
  const isTouchDevice = () => {
    return ("ontouchstart" in window) || (navigator.maxTouchPoints || 0) > 0 || (navigator.msMaxTouchPoints || 0) > 0;
  };

  const prefersReduceMotion = () => {
    try { return window.matchMedia('(prefers-reduced-motion: reduce)').matches; } catch(_) { return false; }
  };

  const initBackground = (container) => {
    const sides = container.querySelector('.A_InspectraBackground-Sides');
    if(!sides) return;
    const circles = Array.from(sides.querySelectorAll('.Q_BackgroundCircle'));
    if(circles.length < 2) return;

    const strengthPx = 96;
    let targetX = 0, targetY = 0;
    let currX = 0, currY = 0;
    let raf = null;

    const clamp = (v, min, max) => Math.max(min, Math.min(max, v));

    const animate = () => {
      raf = null;
      currX += (targetX - currX) * 0.08;
      currY += (targetY - currY) * 0.08;

      const leftTx = `translate(${-strengthPx * currX}px, ${-strengthPx * currY}px)`;
      const rightTx = `translate(${strengthPx * currX}px, ${strengthPx * currY}px)`;
      if (circles[0]) circles[0].style.transform = leftTx;
      if (circles[1]) circles[1].style.transform = rightTx;

      if (Math.abs(currX - targetX) > 0.001 || Math.abs(currY - targetY) > 0.001) {
        raf = requestAnimationFrame(animate);
      }
    };

    const onMove = (e) => {
      const rect = container.getBoundingClientRect();
      const cx = rect.left + rect.width / 2;
      const cy = rect.top + rect.height / 2;
      const nx = clamp((e.clientX - cx) / (rect.width / 2), -1, 1);
      const ny = clamp((e.clientY - cy) / (rect.height / 2), -1, 1);
      targetX = nx; targetY = ny;
      if(!raf) raf = requestAnimationFrame(animate);
    };

    const onLeave = () => {
      targetX = 0; targetY = 0;
      if(!raf) raf = requestAnimationFrame(animate);
    };

    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseleave', onLeave);
  };

  const boot = () => {
    if (isTouchDevice() || prefersReduceMotion()) return;
    document.querySelectorAll('.A_InspectraBackground').forEach(initBackground);
  };

  window.addEventListener('DOMContentLoaded', boot);
  document.addEventListener('turbo:load', boot);
})();


