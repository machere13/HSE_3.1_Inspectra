(function() {
  const DRAG_HEADER_SELECTOR = '[data-js-control-panel-drag]';
  const DRAG_IGNORE_SELECTOR = '.W_ControlPanel-Header-Button';
  const RESIZE_SELECTORS = [
    ['[data-js-console-resize-left]', { w: true }],
    ['[data-js-console-resize-right]', { e: true }],
    ['[data-js-console-resize-top]', { n: true }],
    ['[data-js-console-resize-bottom]', { s: true }],
    ['[data-js-console-resize-nw]', { n: true, w: true }],
    ['[data-js-console-resize-ne]', { n: true, e: true }],
    ['[data-js-console-resize-sw]', { s: true, w: true }],
    ['[data-js-console-resize-se]', { s: true, e: true }]
  ];

  function initPanelDrag(panelEl, options) {
    if (!panelEl) return;
    const opts = options || {};
    const verticalOnly = opts.verticalOnly === true;
    const ignoreSelector = opts.ignoreSelector != null ? opts.ignoreSelector : DRAG_IGNORE_SELECTOR;
    const onDragEnd = opts.onDragEnd;

    if (verticalOnly) {
      panelEl.querySelectorAll('.W_ControlPanel-Resize').forEach(function(el) { el.style.display = 'none'; });
    }

    const header = panelEl.querySelector(DRAG_HEADER_SELECTOR);
    if (!header) return;

    header.addEventListener('mousedown', (e) => {
      if (e.target.closest(ignoreSelector)) return;
      e.preventDefault();
      panelEl.classList.add('is-dragging');
      const rect = panelEl.getBoundingClientRect();
      const startX = e.clientX - rect.left;
      const startY = e.clientY - rect.top;
      if (verticalOnly) {
        panelEl.style.top = `${rect.top}px`;
        panelEl.style.bottom = 'auto';
      } else {
        panelEl.style.right = '';
        panelEl.style.bottom = '';
      }
      const onMove = (ev) => {
        if (verticalOnly) {
          const y = Math.max(0, Math.min(ev.clientY - startY, window.innerHeight - 50));
          panelEl.style.top = `${y}px`;
        } else {
          const x = Math.max(0, Math.min(ev.clientX - startX, window.innerWidth - 50));
          const y = Math.max(0, Math.min(ev.clientY - startY, window.innerHeight - 50));
          panelEl.style.left = `${x}px`;
          panelEl.style.top = `${y}px`;
          panelEl.style.right = 'auto';
          panelEl.style.bottom = 'auto';
        }
      };
      const onUp = () => {
        panelEl.classList.remove('is-dragging');
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
        if (typeof onDragEnd === 'function') onDragEnd(panelEl);
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });
  }

  function initPanelResize(panelEl, options) {
    if (!panelEl) return;
    const opts = options || {};
    const minW = opts.minW != null ? opts.minW : 280;
    const minH = opts.minH != null ? opts.minH : 200;
    const pad = opts.pad != null ? opts.pad : 16;
    const onResizeStart = opts.onResizeStart;
    const onResizeEnd = opts.onResizeEnd;

    RESIZE_SELECTORS.forEach(function(item) {
      const selector = item[0];
      const edges = item[1];
      const el = panelEl.querySelector(selector);
      if (!el) return;
      el.addEventListener('mousedown', (e) => {
        e.preventDefault();
        panelEl.classList.add('is-dragging');
        const rect = panelEl.getBoundingClientRect();
        if (typeof onResizeStart === 'function') onResizeStart(panelEl, rect);
        panelEl.style.right = '';
        panelEl.style.bottom = '';

        const start = {
          left: rect.left,
          top: rect.top,
          right: rect.left + rect.width,
          bottom: rect.top + rect.height,
          x: e.clientX,
          y: e.clientY
        };

        const onMove = (ev) => {
          let left = edges.w ? start.left + (ev.clientX - start.x) : start.left;
          let right = edges.e ? start.right + (ev.clientX - start.x) : start.right;
          let top = edges.n ? start.top + (ev.clientY - start.y) : start.top;
          let bottom = edges.s ? start.bottom + (ev.clientY - start.y) : start.bottom;
          if (right - left < minW) {
            if (edges.w) left = right - minW;
            else right = left + minW;
          }
          if (bottom - top < minH) {
            if (edges.n) top = bottom - minH;
            else bottom = top + minH;
          }
          const vw = window.innerWidth - pad;
          const vh = window.innerHeight - pad;
          left = Math.max(0, Math.min(left, vw - minW));
          right = Math.max(left + minW, Math.min(right, vw));
          top = Math.max(0, Math.min(top, vh - minH));
          bottom = Math.max(top + minH, Math.min(bottom, vh));
          panelEl.style.left = left + 'px';
          panelEl.style.top = top + 'px';
          panelEl.style.width = (right - left) + 'px';
          panelEl.style.height = (bottom - top) + 'px';
        };
        const onUp = () => {
          panelEl.classList.remove('is-dragging');
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
          if (typeof onResizeEnd === 'function') onResizeEnd(panelEl);
        };
        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    });
  }

  window.W_ControlPanel = {
    initPanelDrag,
    initPanelResize
  };
})();
