(() => {
  const RESIZE = { MIN_W: 280, MIN_H: 200 };

  const formatTime = (s) => {
    if (!Number.isFinite(s) || s < 0) return '00:00';
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return `${(m < 10 ? '0' : '') + m}:${(sec < 10 ? '0' : '') + sec}`;
  };

  let playlist = [];
  let currentIndex = 0;
  let loopOne = false;

  function setPlaylist(urls, index) {
    playlist = Array.isArray(urls) ? urls.filter(Boolean) : [];
    currentIndex = Math.max(0, Math.min(index | 0, Math.max(0, playlist.length - 1)));
  }

  function openInPreview(url) {
    const template = document.getElementById('js-audio-player-template');
    if (!template || !template.firstElementChild) return null;
    if (playlist.length === 0 && url) {
      playlist = [url];
      currentIndex = 0;
    }
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

  function initPanel(panelEl, onClose, options) {
    if (!panelEl) return;
    const opts = options || {};
    const verticalOnly = opts.verticalOnly === true;

    const closeBtn = panelEl.querySelector('[data-js-console-close]');
    const maxBtn = panelEl.querySelector('[data-js-console-maximize]');
    closeBtn?.addEventListener('click', () => { if (onClose) onClose(); });

    maxBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      if (panelEl.classList.contains('W_ControlPanel--in-preview')) {
        transferInPreviewToGlobal(panelEl, onClose);
        return;
      }
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
      if (verticalOnly) {
        panelEl.style.top = `${rect.top}px`;
        panelEl.style.bottom = 'auto';
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
        }
      };
      const onUp = () => {
        panelEl.classList.remove('is-dragging');
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });

    if (verticalOnly) {
      const resizeHandles = panelEl.querySelectorAll('.W_ControlPanel-Resize');
      resizeHandles.forEach((el) => { el.style.display = 'none'; });
    }

    const bindResize = (selector, edges) => {
      if (verticalOnly) return;
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

  const GLOBAL_CONTAINER_ID = 'js-global-audio-player-container';
  const GLOBAL_PANEL_ID = 'js-global-audio-player';
  let globalInited = false;

  function transferInPreviewToGlobal(panelEl, onClose) {
    const root = panelEl.querySelector('[data-js-audio-player-body], .O_AudioPlayer, .O_GlobalAudioPlayer');
    const audio = root?.querySelector('[data-js-audio-player-src]');
    const volumeInput = root?.querySelector('[data-js-volume-input]');
    if (!audio) return;
    const src = audio.src || audio.currentSrc || '';
    const currentTime = audio.currentTime;
    const paused = audio.paused;
    const vol = audio.volume;
    const sliderVal = volumeInput ? String(Math.round(vol * 10)) : '10';

    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    if (!container) return;
    const isHidden = container.getAttribute('aria-hidden') === 'true' || container.style.display === 'none';
    if (isHidden) {
      container.style.display = '';
      container.setAttribute('aria-hidden', 'false');
      initGlobal();
    }

    const globalBar = document.getElementById(GLOBAL_PANEL_ID);
    const globalRoot = globalBar?.querySelector('[data-js-audio-player-body]') || globalBar;
    const globalAudio = globalRoot?.querySelector('[data-js-audio-player-src]');
    const globalVolumeInput = globalRoot?.querySelector('[data-js-volume-input]');
    const globalVolumeFill = globalRoot?.querySelector('[data-js-volume-fill]');
    if (!globalAudio) return;
    globalAudio.src = src;
    globalAudio.currentTime = currentTime;
    globalAudio.volume = vol;
    if (globalVolumeInput) {
      globalVolumeInput.value = sliderVal;
      globalVolumeInput.dispatchEvent(new Event('input'));
    }
    if (globalVolumeFill) globalVolumeFill.style.height = `${vol * 100}%`;
    if (!paused && src) globalAudio.play().catch(() => {});

    if (onClose) onClose();
  }

  function initGlobal() {
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    const bar = document.getElementById(GLOBAL_PANEL_ID);
    if (!container || !bar || globalInited) return;
    globalInited = true;
    attach(container);
  }

  function toggleGlobal() {
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    const bar = document.getElementById(GLOBAL_PANEL_ID);
    if (!container || !bar) return;
    const isHidden = container.getAttribute('aria-hidden') === 'true' || container.style.display === 'none';
    if (isHidden) {
      container.style.display = '';
      container.setAttribute('aria-hidden', 'false');
      initGlobal();
    } else {
      container.style.display = 'none';
      container.setAttribute('aria-hidden', 'true');
    }
  }

  function bindGlobalToggle() {
    document.querySelectorAll('[data-js-audio-player-toggle]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleGlobal();
      });
    });
  }

  function attach(container, options) {
    const panelEl = container.querySelector('.W_ControlPanel');
    const root = container.querySelector('[data-js-audio-player-body], .O_AudioPlayer, .O_GlobalAudioPlayer');
    if (!root) return;
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
      return raw / 10;
    };
    const updateVolumeFill = () => {
      if (volumeFill && volumeInput) {
        const vol = volumeFromInput();
        volumeFill.style.height = `${vol * 100}%`;
      }
    };

    function applySeek() {
      const p = Number(seekInput?.value) || 0;
      if (audio.duration && Number.isFinite(audio.duration)) {
        audio.currentTime = (p / 100) * audio.duration;
      }
      updateProgress();
    }

    audio.addEventListener('timeupdate', () => { updateTime(); updateProgress(); });
    audio.addEventListener('durationchange', () => { updateProgress(); updateDuration(); });
    audio.addEventListener('loadedmetadata', () => { updateProgress(); updateDuration(); });
    audio.addEventListener('ended', () => {
      if (loopOne) {
        audio.currentTime = 0;
        audio.play().catch(() => {});
      }
    });
    playBtn?.addEventListener('click', () => { if (audio.paused) audio.play().catch(() => {}); else audio.pause(); });
    seekInput?.addEventListener('input', applySeek);
    seekInput?.addEventListener('change', applySeek);

    const prevBtn = root.querySelector('[data-js-audio-prev]');
    const nextBtn = root.querySelector('[data-js-audio-next]');
    const loopBtn = root.querySelector('[data-js-audio-loop]');
    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        if (audio.currentTime > 3) {
          audio.currentTime = 0;
          updateProgress();
        } else if (currentIndex > 0) {
          currentIndex--;
          audio.src = playlist[currentIndex] || '';
          audio.load();
          audio.play().catch(() => {});
        }
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        if (currentIndex < playlist.length - 1) {
          currentIndex++;
          audio.src = playlist[currentIndex] || '';
          audio.load();
          audio.play().catch(() => {});
        }
      });
    }
    if (loopBtn) {
      loopBtn.addEventListener('click', () => {
        loopOne = !loopOne;
        loopBtn.classList.toggle('is-active', loopOne);
      });
      loopBtn.classList.toggle('is-active', loopOne);
    }
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
        audio.volume = volumeFromInput();
        updateVolumeFill();
      });
      volumeInput.addEventListener('change', updateVolumeFill);
      updateVolumeFill();
    }

    if (container.id === GLOBAL_CONTAINER_ID && root.querySelector('[data-js-audio-player-body]')) {
      if (playlist.length === 0 && audio.src) {
        playlist = [audio.src];
        currentIndex = 0;
      }
    } else if (playlist.length === 0 && audio.src) {
      playlist = [audio.src];
      currentIndex = 0;
    }

    if (panelEl) {
      const onClose = (options && options.onClose) || (() => {
        if (window.ContentPreview && typeof window.ContentPreview.closePreview === 'function') {
          window.ContentPreview.closePreview();
        }
      });
      initPanel(panelEl, onClose, options);
    }
  }

  window.O_AudioPlayer = {
    openInPreview,
    attach,
    setPlaylist,
    toggleGlobal,
    bindGlobalToggle
  };

  if (window.DomUtils) {
    window.DomUtils.ready(bindGlobalToggle);
    if (window.DomUtils.turboLoad) window.DomUtils.turboLoad(bindGlobalToggle);
  } else {
    document.addEventListener('DOMContentLoaded', bindGlobalToggle);
  }
})();
