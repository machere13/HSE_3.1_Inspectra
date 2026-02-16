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

  const DEBUG = typeof window !== 'undefined' && window.location && (window.location.hostname === 'localhost' || window.location.search.includes('debug=1'));

  function setPlaylist(urls, index) {
    playlist = Array.isArray(urls) ? urls.filter(Boolean) : [];
    currentIndex = Math.max(0, Math.min(index | 0, Math.max(0, playlist.length - 1)));
    if (DEBUG) console.log('[O_AudioPlayer] setPlaylist', { urls: playlist.length, currentIndex, playlist: playlist.map(u => u.slice(-30)) });
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
  const STORAGE_KEY_VISIBLE = 'globalAudioPlayerVisible';
  const STORAGE_KEY_SRC = 'globalAudioPlayerSrc';
  const STORAGE_KEY_TIME = 'globalAudioPlayerTime';
  const STORAGE_KEY_PAUSED = 'globalAudioPlayerPaused';
  let globalInited = false;

  function saveGlobalAudioState() {
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    if (!container || container.style.display === 'none' || container.getAttribute('aria-hidden') === 'true') return;
    const root = container.querySelector('[data-js-audio-player-body], .O_GlobalAudioPlayer');
    const audio = root?.querySelector('[data-js-audio-player-src]');
    if (!audio || !audio.src) return;
    try {
      sessionStorage.setItem(STORAGE_KEY_SRC, audio.src);
      sessionStorage.setItem(STORAGE_KEY_TIME, String(audio.currentTime));
      sessionStorage.setItem(STORAGE_KEY_PAUSED, audio.paused ? '1' : '0');
    } catch (e) {}
  }

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
      try { sessionStorage.setItem(STORAGE_KEY_VISIBLE, '1'); } catch (e) {}
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
    if (!container || !bar) return;
    if (container.getAttribute('data-audio-inited') === 'true') return;
    container.setAttribute('data-audio-inited', 'true');
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
      try { sessionStorage.setItem(STORAGE_KEY_VISIBLE, '1'); } catch (e) {}
      initGlobal();
    } else {
      container.style.display = 'none';
      container.setAttribute('aria-hidden', 'true');
      try { sessionStorage.removeItem(STORAGE_KEY_VISIBLE); } catch (e) {}
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
    function loadTrack(index) {
      const src = playlist[index];
      if (src == null || src === '') return;
      audio.src = src;
      audio.load();
      const playAfterLoad = () => {
        audio.play().catch(() => {});
      };
      audio.addEventListener('loadeddata', playAfterLoad, { once: true });
      audio.addEventListener('error', () => {}, { once: true });
    }
    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        if (DEBUG) console.log('[O_AudioPlayer] prev click', { currentIndex, playlistLength: playlist.length, currentTime: audio.currentTime });
        if (audio.currentTime > 3) {
          audio.currentTime = 0;
          updateProgress();
        } else if (currentIndex > 0) {
          currentIndex--;
          loadTrack(currentIndex);
        }
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        if (DEBUG) console.log('[O_AudioPlayer] next click', { currentIndex, playlistLength: playlist.length });
        if (currentIndex < playlist.length - 1) {
          currentIndex++;
          loadTrack(currentIndex);
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

  function restoreGlobalPlayerAfterNavigate() {
    let stored = '';
    try { stored = sessionStorage.getItem(STORAGE_KEY_VISIBLE) || ''; } catch (e) {}
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    const hidden = container ? (container.style.display === 'none' || container.getAttribute('aria-hidden') === 'true') : null;
    console.log('[O_AudioPlayer] turbo:load restore', {
      stored,
      hasContainer: !!container,
      hidden,
      inited: container ? container.getAttribute('data-audio-inited') : null
    });
    if (stored !== '1') return;
    if (!container) return;
    if (container.style.display === 'none' || container.getAttribute('aria-hidden') === 'true') {
      container.style.display = '';
      container.setAttribute('aria-hidden', 'false');
      if (container.getAttribute('data-audio-inited') !== 'true') {
        globalInited = false;
      }
      initGlobal();
      let savedSrc = '';
      let savedTime = '0';
      let savedPaused = '1';
      try {
        savedSrc = sessionStorage.getItem(STORAGE_KEY_SRC) || '';
        savedTime = sessionStorage.getItem(STORAGE_KEY_TIME) || '0';
        savedPaused = sessionStorage.getItem(STORAGE_KEY_PAUSED) || '1';
      } catch (e) {}
      if (savedSrc) {
        playlist = [savedSrc];
        currentIndex = 0;
        const root = container.querySelector('[data-js-audio-player-body], .O_GlobalAudioPlayer');
        const audio = root?.querySelector('[data-js-audio-player-src]');
        if (audio) {
          audio.src = savedSrc;
          audio.load();
          const time = parseFloat(savedTime);
          const shouldPlay = savedPaused !== '1';
          audio.addEventListener('loadedmetadata', () => {
            if (Number.isFinite(time) && time > 0) audio.currentTime = time;
            if (shouldPlay) audio.play().catch(() => {});
          }, { once: true });
        }
      }
    }
  }

  if (window.DomUtils) {
    window.DomUtils.ready(bindGlobalToggle);
    window.DomUtils.ready(restoreGlobalPlayerAfterNavigate);
    if (window.DomUtils.turboLoad) {
      window.DomUtils.turboLoad(bindGlobalToggle);
      window.DomUtils.turboLoad(restoreGlobalPlayerAfterNavigate);
    }
  } else {
    document.addEventListener('DOMContentLoaded', bindGlobalToggle);
    document.addEventListener('DOMContentLoaded', restoreGlobalPlayerAfterNavigate);
  }
  document.addEventListener('turbo:load', restoreGlobalPlayerAfterNavigate);
  document.addEventListener('turbo:before-visit', saveGlobalAudioState);
  document.addEventListener('turbo:before-cache', saveGlobalAudioState);
})();
