(() => {
  const RESIZE = { MIN_W: 280, MIN_H: 200 };

  const formatTime = (s) => {
    if (!Number.isFinite(s) || s < 0) return '00:00';
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return `${(m < 10 ? '0' : '') + m}:${(sec < 10 ? '0' : '') + sec}`;
  };

  function openInPreview(url) {
    const template = document.getElementById('js-audio-player-template');
    if (!template || !template.firstElementChild) return null;
    const panel = template.firstElementChild.cloneNode(true);
    panel.removeAttribute('id');
    panel.style.display = '';
    panel.removeAttribute('aria-hidden');
    panel.classList.add('W_ControlPanel--in-preview');
    const audio = panel.querySelector('[data-js-audio-player-src]');
    if (audio) {
      audio.src = url || '';
      audio.load();
    }
    return panel;
  }

  function initPanel(panelEl, onClose) {
    if (!panelEl) return;
    const closeBtn = panelEl.querySelector('[data-js-console-close]');
    const maxBtn = panelEl.querySelector('[data-js-console-maximize]');
    closeBtn?.addEventListener('click', () => { if (onClose) onClose(); });

    maxBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      panelEl.classList.toggle('is-maximized');
      maxBtn.setAttribute('aria-label', panelEl.classList.contains('is-maximized') ? 'Выйти из полноэкранного режима' : 'На весь экран');
    });

    const header = panelEl.querySelector('[data-js-control-panel-drag]');
    header?.addEventListener('mousedown', (e) => {
      if (e.target.closest('.W_ControlPanel-Header-Button')) return;
      e.preventDefault();
      panelEl.classList.add('is-dragging');
      const rect = panelEl.getBoundingClientRect();
      const startX = e.clientX - rect.left;
      const startY = e.clientY - rect.top;
      const onMove = (ev) => {
        const x = Math.max(0, Math.min(ev.clientX - startX, window.innerWidth - 50));
        const y = Math.max(0, Math.min(ev.clientY - startY, window.innerHeight - 50));
        panelEl.style.left = `${x}px`;
        panelEl.style.top = `${y}px`;
      };
      const onUp = () => {
        panelEl.classList.remove('is-dragging');
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });

    const bindResize = (selector, edges) => {
      const el = panelEl.querySelector(selector);
      if (!el) return;
      el.addEventListener('mousedown', (e) => {
        e.preventDefault();
        panelEl.classList.add('is-dragging');
        const rect = panelEl.getBoundingClientRect();
        const start = { left: rect.left, top: rect.top, right: rect.left + rect.width, bottom: rect.top + rect.height, x: e.clientX, y: e.clientY };
        const onMove = (ev) => {
          let left = edges.w ? start.left + (ev.clientX - start.x) : start.left;
          let right = edges.e ? start.right + (ev.clientX - start.x) : start.right;
          let top = edges.n ? start.top + (ev.clientY - start.y) : start.top;
          let bottom = edges.s ? start.bottom + (ev.clientY - start.y) : start.bottom;
          if (right - left < RESIZE.MIN_W) { if (edges.w) left = right - RESIZE.MIN_W; else right = left + RESIZE.MIN_W; }
          if (bottom - top < RESIZE.MIN_H) { if (edges.n) top = bottom - RESIZE.MIN_H; else bottom = top + RESIZE.MIN_H; }
          panelEl.style.left = `${left}px`;
          panelEl.style.top = `${top}px`;
          panelEl.style.width = `${right - left}px`;
          panelEl.style.height = `${bottom - top}px`;
        };
        const onUp = () => {
          panelEl.classList.remove('is-dragging');
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
        };
        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    };
    bindResize('[data-js-console-resize-left]', { w: true });
    bindResize('[data-js-console-resize-right]', { e: true });
    bindResize('[data-js-console-resize-top]', { n: true });
    bindResize('[data-js-console-resize-bottom]', { s: true });
    bindResize('[data-js-console-resize-nw]', { n: true, w: true });
    bindResize('[data-js-console-resize-ne]', { n: true, e: true });
    bindResize('[data-js-console-resize-sw]', { s: true, w: true });
    bindResize('[data-js-console-resize-se]', { s: true, e: true });
  }

  function attach(container) {
    const panelEl = container.querySelector('.W_ControlPanel');
    const root = container.querySelector('[data-js-audio-player-body], .O_AudioPlayer');
    if (!root || !panelEl) return;
    const audio = root.querySelector('[data-js-audio-player-src]');
    const playBtn = root.querySelector('[data-js-audio-player-play]');
    const timeEl = root.querySelector('[data-js-audio-player-time]');
    const durationEl = root.querySelector('[data-js-audio-player-duration]');
    const progressFill = root.querySelector('[data-js-timeline-fill]');
    const seekInput = root.querySelector('[data-js-timeline-seek]');
    const volumeInput = root.querySelector('[data-js-volume-input]');
    const volumeFill = root.querySelector('[data-js-volume-fill]');
    if (!audio) return;

    const updateTime = () => { if (timeEl) timeEl.textContent = formatTime(audio.currentTime); };
    const updateDuration = () => { if (durationEl) durationEl.textContent = formatTime(audio.duration); };
    const updateProgress = () => {
      const p = audio.duration ? (audio.currentTime / audio.duration) * 100 : 0;
      if (progressFill) progressFill.style.width = `${p}%`;
      if (seekInput) seekInput.value = p;
    };
    const volumeFromInput = () => {
      const raw = Number(volumeInput?.value);
      if (Number.isNaN(raw)) return 1;
      return (10 - raw) / 10;
    };
    const updateVolumeFill = () => {
      if (volumeFill && volumeInput) {
        const vol = volumeFromInput();
        volumeFill.style.height = `${vol * 100}%`;
      }
    };

    audio.addEventListener('timeupdate', () => { updateTime(); updateProgress(); });
    audio.addEventListener('durationchange', () => { updateProgress(); updateDuration(); });
    audio.addEventListener('loadedmetadata', () => { updateProgress(); updateDuration(); });
    playBtn?.addEventListener('click', () => { if (audio.paused) audio.play().catch(() => {}); else audio.pause(); });
    seekInput?.addEventListener('input', () => {
      const p = Number(seekInput.value) || 0;
      if (audio.duration) audio.currentTime = (p / 100) * audio.duration;
      updateProgress();
    });
    const volumeWrap = root.querySelector('[data-js-audio-player-volume]');
    const volumeToggle = root.querySelector('[data-js-audio-player-volume-toggle]');
    if (volumeToggle && volumeWrap) {
      volumeToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        const isOpen = volumeWrap.classList.toggle('is-open');
        volumeToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
      });
      document.addEventListener('click', (e) => {
        if (!volumeWrap.contains(e.target)) {
          volumeWrap.classList.remove('is-open');
          volumeToggle.setAttribute('aria-expanded', 'false');
        }
      });
    }
    if (volumeInput) {
      audio.volume = 1;
      volumeInput.addEventListener('input', () => {
        const raw = Number(volumeInput.value);
        const value = Number.isNaN(raw) ? 10 : raw;
        audio.volume = value / 10;
        updateVolumeFill();
      });
      volumeInput.addEventListener('change', updateVolumeFill);
      updateVolumeFill();
    }

    initPanel(panelEl, () => {
      if (window.ContentPreview && typeof window.ContentPreview.closePreview === 'function') {
        window.ContentPreview.closePreview();
      }
    });
  }

  window.O_AudioPlayer = {
    openInPreview,
    attach
  };
})();
