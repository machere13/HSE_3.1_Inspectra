(() => {
  const RESIZE = { MIN_W: 280, MIN_H: 200 };

  const formatTime = (s) => {
    if (!Number.isFinite(s) || s < 0) return '00:00';
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return `${(m < 10 ? '0' : '') + m}:${(sec < 10 ? '0' : '') + sec}`;
  };

  let playlist = [];
  let playlistTitles = [];
  let currentIndex = 0;
  let loopOne = false;

  function setPlaylist(urls, index, titles) {
    playlist = Array.isArray(urls) ? urls.filter(Boolean) : [];
    currentIndex = Math.max(0, Math.min(index | 0, Math.max(0, playlist.length - 1)));
    playlistTitles = Array.isArray(titles) ? titles.slice(0, playlist.length) : [];
    while (playlistTitles.length < playlist.length) playlistTitles.push('');
    if (playlist.length > 0) persistGlobalState();
  }

  function updateGlobalTitle() {
    const bar = document.getElementById(GLOBAL_PANEL_ID);
    const el = bar?.querySelector('[data-js-audio-player-title]');
    if (el) el.textContent = playlistTitles[currentIndex] || '';
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
  const STORAGE_KEY_PLAYLIST = 'globalAudioPlayerPlaylist';
  const STORAGE_KEY_INDEX = 'globalAudioPlayerIndex';
  const STORAGE_KEY_TIME = 'globalAudioPlayerTime';
  const STORAGE_KEY_PAUSED = 'globalAudioPlayerPaused';
  const STORAGE_KEY_POSITION = 'globalAudioPlayerPosition';
  const DATA_ATTR_PLAYLIST = 'data-global-playlist';
  const DATA_ATTR_INDEX = 'data-global-index';
  const DATA_ATTR_TITLES = 'data-global-titles';
  const DATA_ATTR_SRC = 'data-global-src';
  const DATA_ATTR_TIME = 'data-global-time';
  const DATA_ATTR_PAUSED = 'data-global-paused';
  const STORAGE_KEY_TITLES = 'globalAudioPlayerTitles';
  let globalInited = false;

  function persistGlobalState() {
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    if (!container) return;
    const root = container.querySelector('[data-js-audio-player-body], .O_GlobalAudioPlayer');
    const audio = root?.querySelector('[data-js-audio-player-src]');
    try {
      if (playlist.length > 0) {
        const json = JSON.stringify(playlist);
        container.setAttribute(DATA_ATTR_PLAYLIST, json);
        container.setAttribute(DATA_ATTR_INDEX, String(currentIndex));
        if (playlistTitles.length) {
          const titlesJson = JSON.stringify(playlistTitles);
          container.setAttribute(DATA_ATTR_TITLES, titlesJson);
          sessionStorage.setItem(STORAGE_KEY_TITLES, titlesJson);
        }
        sessionStorage.setItem(STORAGE_KEY_PLAYLIST, json);
        sessionStorage.setItem(STORAGE_KEY_INDEX, String(currentIndex));
      }
      if (audio && audio.src) {
        container.setAttribute(DATA_ATTR_SRC, audio.src);
        container.setAttribute(DATA_ATTR_TIME, String(audio.currentTime));
        container.setAttribute(DATA_ATTR_PAUSED, audio.paused ? '1' : '0');
        sessionStorage.setItem(STORAGE_KEY_SRC, audio.src);
        sessionStorage.setItem(STORAGE_KEY_TIME, String(audio.currentTime));
        sessionStorage.setItem(STORAGE_KEY_PAUSED, audio.paused ? '1' : '0');
      }
    } catch (e) {}
  }

  function applyGlobalPosition(container, position) {
    if (!container) return;
    const bar = container.querySelector('.O_GlobalAudioPlayer');
    const isTop = position === 'top';
    container.classList.toggle('is-at-top', isTop);
    container.setAttribute('data-global-player-position', position || 'bottom');
    if (bar) bar.classList.toggle('is-at-top', isTop);
    try { sessionStorage.setItem(STORAGE_KEY_POSITION, isTop ? 'top' : 'bottom'); } catch (e) {}
  }

  const GLOBAL_DRAG_IGNORE = 'button, input, [type="range"], a, [role="button"], [data-js-audio-player-volume], [data-js-audio-player-close-global]';

  function bindGlobalDrag(container) {
    const bar = document.getElementById(GLOBAL_PANEL_ID);
    if (!container || !bar) return;
    let startY = 0;
    let startTransform = 0;
    let currentTransform = 0;
    bar.addEventListener('mousedown', (e) => {
      if (e.button !== 0) return;
      if (e.target.closest(GLOBAL_DRAG_IGNORE)) return;
      e.preventDefault();
      bar.classList.add('is-dragging');
      startY = e.clientY;
      startTransform = currentTransform;
      const onMove = (ev) => {
        currentTransform = startTransform + (ev.clientY - startY);
        container.style.transform = `translateY(${currentTransform}px)`;
      };
      const onUp = () => {
        bar.classList.remove('is-dragging');
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
        container.style.transform = '';
        currentTransform = 0;
        const rect = bar.getBoundingClientRect();
        const centerY = rect.top + rect.height / 2;
        const position = centerY < window.innerHeight / 2 ? 'top' : 'bottom';
        applyGlobalPosition(container, position);
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });
  }

  function saveGlobalAudioState() {
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    if (!container || container.style.display === 'none' || container.getAttribute('aria-hidden') === 'true') return;
    const root = container.querySelector('[data-js-audio-player-body], .O_GlobalAudioPlayer');
    const audio = root?.querySelector('[data-js-audio-player-src]');
    if (!audio || !audio.src) return;
    persistGlobalState();
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

    persistGlobalState();
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
      let pos = '';
      try { pos = sessionStorage.getItem(STORAGE_KEY_POSITION) || 'bottom'; } catch (e) {}
      applyGlobalPosition(container, pos === 'top' ? 'top' : 'bottom');
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
    let lastPersistTime = 0;
    if (container.id === GLOBAL_CONTAINER_ID) {
      audio.addEventListener('timeupdate', () => {
        const now = Date.now();
        if (now - lastPersistTime >= 1000) {
          lastPersistTime = now;
          persistGlobalState();
        }
      });
    }
    audio.addEventListener('ended', () => {
      if (loopOne) {
        audio.currentTime = 0;
        audio.play().catch(() => {});
      }
    });
    playBtn?.addEventListener('click', () => { if (audio.paused) audio.play().catch(() => {}); else audio.pause(); });
    seekInput?.addEventListener('input', applySeek);
    seekInput?.addEventListener('change', applySeek);
    const timelineEl = root.querySelector('[data-js-timeline]');
    if (timelineEl && seekInput) {
      timelineEl.addEventListener('click', (e) => {
        if (e.target === seekInput || seekInput.contains(e.target)) return;
        const rect = timelineEl.getBoundingClientRect();
        if (rect.width <= 0) return;
        const p = Math.max(0, Math.min(100, ((e.clientX - rect.left) / rect.width) * 100));
        seekInput.value = p;
        applySeek();
      });
    }

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
        if (audio.currentTime > 3) {
          audio.currentTime = 0;
          updateProgress();
        } else if (currentIndex > 0) {
          currentIndex--;
          loadTrack(currentIndex);
          if (container.id === GLOBAL_CONTAINER_ID) {
            persistGlobalState();
            updateGlobalTitle();
          }
        }
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        if (currentIndex < playlist.length - 1) {
          currentIndex++;
          loadTrack(currentIndex);
          if (container.id === GLOBAL_CONTAINER_ID) {
            persistGlobalState();
            updateGlobalTitle();
          }
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
    const closeGlobalBtn = root.querySelector('[data-js-audio-player-close-global]');
    if (closeGlobalBtn && container.id === GLOBAL_CONTAINER_ID) {
      closeGlobalBtn.addEventListener('click', () => { toggleGlobal(); });
    }
    if (container.id === GLOBAL_CONTAINER_ID) {
      bindGlobalDrag(container);
      updateGlobalTitle();
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
    if (stored !== '1') return;
    if (!container) return;
    if (container.style.display === 'none' || container.getAttribute('aria-hidden') === 'true') {
      container.style.display = '';
      container.setAttribute('aria-hidden', 'false');
      let pos = 'bottom';
      try { pos = sessionStorage.getItem(STORAGE_KEY_POSITION) || 'bottom'; } catch (e) {}
      applyGlobalPosition(container, pos === 'top' ? 'top' : 'bottom');
      if (container.getAttribute('data-audio-inited') !== 'true') {
        globalInited = false;
      }
      let savedSrc = '';
      let savedPlaylistJson = '';
      let savedTitlesJson = '';
      let savedIndex = '0';
      let savedTime = '0';
      let savedPaused = '1';
      savedPlaylistJson = container.getAttribute(DATA_ATTR_PLAYLIST) || '';
      savedIndex = container.getAttribute(DATA_ATTR_INDEX) || '';
      savedTitlesJson = container.getAttribute(DATA_ATTR_TITLES) || '';
      savedSrc = container.getAttribute(DATA_ATTR_SRC) || '';
      savedTime = container.getAttribute(DATA_ATTR_TIME) || '';
      savedPaused = container.getAttribute(DATA_ATTR_PAUSED) || '';
      if (!savedPlaylistJson || !savedSrc) {
        try {
          if (!savedPlaylistJson) savedPlaylistJson = sessionStorage.getItem(STORAGE_KEY_PLAYLIST) || '';
          if (!savedIndex) savedIndex = sessionStorage.getItem(STORAGE_KEY_INDEX) || '0';
          if (!savedTitlesJson) savedTitlesJson = sessionStorage.getItem(STORAGE_KEY_TITLES) || '';
          if (!savedSrc) savedSrc = sessionStorage.getItem(STORAGE_KEY_SRC) || '';
          if (!savedTime) savedTime = sessionStorage.getItem(STORAGE_KEY_TIME) || '0';
          if (!savedPaused) savedPaused = sessionStorage.getItem(STORAGE_KEY_PAUSED) || '1';
        } catch (e) {}
      }
      if (!savedIndex) savedIndex = '0';
      if (!savedTime) savedTime = '0';
      if (!savedPaused) savedPaused = '1';
      let list = [];
      let titlesList = [];
      if (savedPlaylistJson) {
        try {
          list = JSON.parse(savedPlaylistJson);
          if (!Array.isArray(list)) list = [];
        } catch (e) {}
      }
      if (savedTitlesJson) {
        try {
          titlesList = JSON.parse(savedTitlesJson);
          if (!Array.isArray(titlesList)) titlesList = [];
        } catch (e) {}
      }
      if (list.length === 0 && savedSrc) list = [savedSrc];
      while (titlesList.length < list.length) titlesList.push('');
      const idx = Math.max(0, Math.min(parseInt(savedIndex, 10) || 0, Math.max(0, list.length - 1)));
      if (list.length > 0) {
        playlist = list;
        playlistTitles = titlesList;
        currentIndex = idx;
        const root = container.querySelector('[data-js-audio-player-body], .O_GlobalAudioPlayer');
        const audio = root?.querySelector('[data-js-audio-player-src]');
        const trackSrc = (playlist[currentIndex] || list[0] || '').trim();
        if (audio && trackSrc) {
          const time = Math.max(0, parseFloat(savedTime));
          const shouldPlay = savedPaused !== '1';
          let restored = false;
          const applyRestore = () => {
            if (restored) return;
            restored = true;
            if (Number.isFinite(time)) audio.currentTime = time;
            if (shouldPlay) audio.play().catch(() => {});
          };
          audio.addEventListener('loadedmetadata', applyRestore, { once: true });
          audio.addEventListener('loadeddata', applyRestore, { once: true });
          audio.addEventListener('canplay', applyRestore, { once: true });
          audio.src = trackSrc;
          audio.load();
          if (audio.readyState >= 2) applyRestore();
        }
      }
      initGlobal();
      updateGlobalTitle();
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
