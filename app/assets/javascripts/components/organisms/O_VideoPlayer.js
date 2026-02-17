(() => {
  const GLOBAL_CONTAINER_ID = 'js-global-video-player-container';
  const GLOBAL_PANEL_ID = 'js-global-video-player';
  const GLOBAL_VIDEO_TRANSITION_MS = 280;
  const STORAGE_KEY_VISIBLE = 'globalVideoPlayerVisible';
  const STORAGE_KEY_RECT = 'globalVideoPlayerRect';
  const STORAGE_KEY_VIDEO_STATE = 'globalVideoPlayerState';
  let globalVideoInited = false;
  let playlist = [];
  let playlistTitles = [];
  let currentIndex = 0;

  function setPlaylist(urls, index, titles) {
    playlist = Array.isArray(urls) ? urls.filter(Boolean) : [];
    currentIndex = Math.max(0, Math.min(index | 0, Math.max(0, playlist.length - 1)));
    playlistTitles = Array.isArray(titles) ? titles.slice(0, playlist.length) : [];
    while (playlistTitles.length < playlist.length) playlistTitles.push('');
  }

  function getDefaultRect() {
    return {
      bottom: window.innerHeight - 80,
      width: 420,
      height: 320
    };
  }

  function loadSavedRect() {
    try {
      const raw = sessionStorage.getItem(STORAGE_KEY_RECT);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch (e) {
      return null;
    }
  }

  function saveRect(panelEl) {
    if (!panelEl || panelEl.classList.contains('is-maximized')) return;
    try {
      const rect = panelEl.getBoundingClientRect();
      sessionStorage.setItem(STORAGE_KEY_RECT, JSON.stringify({
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height
      }));
    } catch (e) {}
  }

  function applyRect(panelEl, rect) {
    if (!panelEl || !rect) return;
    panelEl.style.right = '';
    panelEl.style.bottom = '';
    panelEl.style.left = `${rect.left != null ? rect.left : window.innerWidth - rect.width - 20}px`;
    panelEl.style.top = `${rect.top != null ? rect.top : (rect.bottom != null ? rect.bottom - rect.height : window.innerHeight - (rect.height || 320) - 80)}px`;
    panelEl.style.width = `${rect.width || 420}px`;
    panelEl.style.height = `${rect.height || 320}px`;
  }

  function persistVideoState() {
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    const panel = document.getElementById(GLOBAL_PANEL_ID);
    if (!container || !panel || container.getAttribute('aria-hidden') === 'true') return;
    const root = panel.querySelector('[data-js-video-player-body]');
    const video = root?.querySelector('[data-js-video-player-src]');
    if (!video || !video.src) return;
    try {
      sessionStorage.setItem(STORAGE_KEY_VIDEO_STATE, JSON.stringify({
        src: video.src,
        currentTime: video.currentTime,
        paused: video.paused,
        volume: video.volume,
        title: panel.getAttribute('data-video-title') || '',
        playlist: playlist,
        playlistTitles: playlistTitles,
        currentIndex: currentIndex
      }));
    } catch (e) {}
  }

  function loadSavedVideoState() {
    try {
      const raw = sessionStorage.getItem(STORAGE_KEY_VIDEO_STATE);
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  }

  function applySavedVideoState(panel) {
    const state = loadSavedVideoState();
    if (!state || !state.src || !panel) return false;
    if (state.playlist && state.playlist.length) {
      playlist = state.playlist;
      playlistTitles = state.playlistTitles && state.playlistTitles.length ? state.playlistTitles : playlist.map(() => '');
      currentIndex = Math.max(0, Math.min(state.currentIndex | 0, playlist.length - 1));
    }
    const root = panel.querySelector('[data-js-video-player-body]');
    const video = root?.querySelector('[data-js-video-player-src]');
    const volumeInput = root?.querySelector('[data-js-volume-input]');
    const volumeFill = root?.querySelector('[data-js-volume-fill]');
    const titleEl = root?.querySelector('[data-js-video-player-title]');
    if (!video) return false;
    video.src = state.src;
    video.currentTime = state.currentTime != null ? state.currentTime : 0;
    video.volume = state.volume != null ? state.volume : 1;
    if (state.title) panel.setAttribute('data-video-title', state.title);
    if (titleEl && state.title) titleEl.textContent = state.title;
    if (volumeInput) {
      volumeInput.value = String(Math.round((state.volume != null ? state.volume : 1) * 10));
      volumeInput.dispatchEvent(new Event('input'));
    }
    if (volumeFill) volumeFill.style.height = `${(state.volume != null ? state.volume : 1) * 100}%`;
    if (!state.paused) video.play().catch(() => {});
    return true;
  }

  function isWeekPage() {
    const path = typeof window.location !== 'undefined' && window.location.pathname ? window.location.pathname : '';
    return /^\/weeks\//.test(path) && path.indexOf('/articles/') === -1 && path.indexOf('/admin/') === -1;
  }

  function doMinimizeToPreview(panelEl) {
    const root = panelEl.querySelector('[data-js-video-player-body]');
    const video = root?.querySelector('[data-js-video-player-src]');
    if (!video || !video.src) return;
    const url = video.src;
    const title = panelEl.getAttribute('data-video-title') || '';
    const currentTime = video.currentTime;
    const paused = video.paused;
    persistVideoState();
    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    if (container) {
      container.classList.remove('is-visible');
      setTimeout(() => {
        container.style.display = 'none';
        container.setAttribute('aria-hidden', 'true');
        panelEl.setAttribute('aria-hidden', 'true');
        panelEl.style.display = 'none';
        try { sessionStorage.removeItem(STORAGE_KEY_VISIBLE); } catch (err) {}
      }, GLOBAL_VIDEO_TRANSITION_MS);
    }
    if (window.ContentPreview && typeof window.ContentPreview.openVideoPreview === 'function') {
      window.ContentPreview.openVideoPreview(url, { title, currentTime, paused });
    }
  }

  function initGlobalPanel(panelEl) {
    if (!panelEl || panelEl.getAttribute('data-video-global-inited') === 'true') return;
    panelEl.setAttribute('data-video-global-inited', 'true');

    if (window.W_ControlPanel) {
      window.W_ControlPanel.initPanelDrag(panelEl, { onDragEnd: () => saveRect(panelEl) });
      window.W_ControlPanel.initPanelResize(panelEl, { minW: 280, minH: 320, onResizeEnd: () => saveRect(panelEl) });
    }

    const closeBtn = panelEl.querySelector('[data-js-console-close]');
    closeBtn?.addEventListener('click', () => {
      persistVideoState();
      const container = document.getElementById(GLOBAL_CONTAINER_ID);
      if (!container) return;
      container.classList.remove('is-visible');
      setTimeout(() => {
        container.style.display = 'none';
        container.setAttribute('aria-hidden', 'true');
        panelEl.setAttribute('aria-hidden', 'true');
        panelEl.style.display = 'none';
        try { sessionStorage.removeItem(STORAGE_KEY_VISIBLE); } catch (e) {}
      }, GLOBAL_VIDEO_TRANSITION_MS);
    });

    const maxBtn = panelEl.querySelector('[data-js-control-panel-mode]');
    maxBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      if (isWeekPage()) {
        doMinimizeToPreview(panelEl);
        return;
      }
      if (!document.fullscreenElement) {
        panelEl.requestFullscreen().catch(() => {});
      } else {
        document.exitFullscreen();
      }
    });
  }

  function transferToGlobal(previewPanelEl, onClose) {
    const root = previewPanelEl?.querySelector('[data-js-video-player-body]');
    const video = root?.querySelector('[data-js-video-player-src]');
    const volumeInput = root?.querySelector('[data-js-volume-input]');
    if (!video) return;
    const src = video.src || video.currentSrc || '';
    const currentTime = video.currentTime;
    const paused = video.paused;
    const vol = video.volume;
    const title = previewPanelEl.getAttribute('data-video-title') || '';

    const container = document.getElementById(GLOBAL_CONTAINER_ID);
    const globalPanel = document.getElementById(GLOBAL_PANEL_ID);
    if (!container || !globalPanel) return;

    const globalRoot = globalPanel.querySelector('[data-js-video-player-body]');
    const globalVideo = globalRoot?.querySelector('[data-js-video-player-src]');
    const globalVolumeInput = globalRoot?.querySelector('[data-js-volume-input]');
    const globalVolumeFill = globalRoot?.querySelector('[data-js-volume-fill]');
    const globalTitleEl = globalRoot?.querySelector('[data-js-video-player-title]');
    if (!globalVideo) return;

    globalVideo.src = src;
    globalVideo.currentTime = currentTime;
    globalVideo.volume = vol;
    if (!paused && src) globalVideo.play().catch(() => {});
    globalPanel.setAttribute('data-video-title', title);
    if (globalTitleEl) globalTitleEl.textContent = title;
    if (globalVolumeInput) {
      globalVolumeInput.value = String(Math.round(vol * 10));
      globalVolumeInput.dispatchEvent(new Event('input'));
    }
    if (globalVolumeFill) globalVolumeFill.style.height = `${vol * 100}%`;

    const saved = loadSavedRect();
    applyRect(globalPanel, saved || getDefaultRect());
    globalPanel.removeAttribute('aria-hidden');
    globalPanel.style.display = 'flex';
    globalPanel.classList.add('is-visible');
    container.style.display = 'block';
    container.setAttribute('aria-hidden', 'false');
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        container.classList.add('is-visible');
      });
    });
    try { sessionStorage.setItem(STORAGE_KEY_VISIBLE, '1'); } catch (e) {}
    persistVideoState();

    initGlobalPanel(globalPanel);
    if (!globalVideoInited) {
      globalVideoInited = true;
      attach(container);
    }
    if (onClose) onClose();
  }

  function attach(container) {
    const root = container.querySelector('[data-js-video-player-body]');
    if (!root) return;
    const video = root.querySelector('[data-js-video-player-src]');
    const timeEl = root.querySelector('[data-js-video-player-time]');
    const durationEl = root.querySelector('[data-js-video-player-duration]');
    const progressFill = root.querySelector('[data-js-timeline-fill]');
    const seekInput = root.querySelector('[data-js-timeline-seek]');
    const timelineEl = root.querySelector('[data-js-timeline]');
    const volumeInput = root.querySelector('[data-js-volume-input]');
    const volumeFill = root.querySelector('[data-js-volume-fill]');
    const volumeWrap = root.querySelector('[data-js-video-player-volume]');
    const volumeToggle = root.querySelector('[data-js-video-player-volume-toggle]');
    const fullscreenBtn = root.querySelector('[data-js-video-player-fullscreen]');
    const titleEl = root.querySelector('[data-js-video-player-title]');
    const panel = root.closest('.W_ControlPanel');
    if (!video) return;

    if (titleEl && panel && panel.getAttribute('data-video-title')) {
      titleEl.textContent = panel.getAttribute('data-video-title');
    }

    const updateTime = () => { if (timeEl) timeEl.textContent = window.FormatTime(video.currentTime); };
    const updateDuration = () => { if (durationEl) durationEl.textContent = window.FormatTime(video.duration); };
    const updateProgress = () => {
      const p = video.duration ? (video.currentTime / video.duration) * 100 : 0;
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
      if (video.duration && Number.isFinite(video.duration)) {
        video.currentTime = (p / 100) * video.duration;
      }
      updateProgress();
    }

    video.addEventListener('timeupdate', () => { updateTime(); updateProgress(); });
    video.addEventListener('durationchange', () => { updateProgress(); updateDuration(); });
    video.addEventListener('loadedmetadata', () => { updateProgress(); updateDuration(); });
    if (container.id === GLOBAL_CONTAINER_ID) {
      let lastPersist = 0;
      video.addEventListener('timeupdate', () => {
        const now = Date.now();
        if (now - lastPersist >= 1500) {
          lastPersist = now;
          persistVideoState();
        }
      });
    }
    function loadVideoTrack(index) {
      if (!playlist.length || index < 0 || index >= playlist.length) return;
      currentIndex = index;
      const url = playlist[index];
      const title = playlistTitles[index] || '';
      if (panel) panel.setAttribute('data-video-title', title);
      if (titleEl) titleEl.textContent = title;
      video.src = url;
      video.load();
      video.addEventListener('loadeddata', () => { video.play().catch(() => {}); }, { once: true });
      if (container.id === GLOBAL_CONTAINER_ID) persistVideoState();
    }

    const prevBtn = root.querySelector('[data-js-video-player-prev]');
    const nextBtn = root.querySelector('[data-js-video-player-next]');
    if (prevBtn) {
      prevBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        if (currentIndex > 0) loadVideoTrack(currentIndex - 1);
        else if (video.currentTime > 3) {
          video.currentTime = 0;
          updateProgress();
        }
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        if (currentIndex < playlist.length - 1) loadVideoTrack(currentIndex + 1);
      });
    }

    root.querySelectorAll('[data-js-video-player-play]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        if (video.paused) video.play().catch(() => {});
        else video.pause();
      });
    });
    video.addEventListener('click', () => {
      if (video.paused) video.play().catch(() => {});
      else video.pause();
    });

    if (seekInput) {
      seekInput.addEventListener('input', applySeek);
      seekInput.addEventListener('change', applySeek);
    }
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
      video.volume = 1;
      volumeInput.addEventListener('input', () => {
        video.volume = volumeFromInput();
        updateVolumeFill();
      });
      volumeInput.addEventListener('change', updateVolumeFill);
      updateVolumeFill();
    }

    if (fullscreenBtn && panel) {
      fullscreenBtn.addEventListener('click', () => {
        if (!document.fullscreenElement) {
          panel.requestFullscreen().catch(() => {});
        } else {
          document.exitFullscreen();
        }
      });
      document.addEventListener('fullscreenchange', () => {
        if (document.fullscreenElement === panel) {
          panel.classList.add('is-fullscreen');
        } else {
          panel.classList.remove('is-fullscreen');
        }
      });
    }

    const panelEl = container.querySelector('.W_ControlPanel');
    const isGlobalContainer = container.id === GLOBAL_CONTAINER_ID;
    if (panelEl && !isGlobalContainer) {
      const closeBtn = panelEl.querySelector('[data-js-console-close]');
      const maxBtn = panelEl.querySelector('[data-js-control-panel-mode]');
      const isInPreview = panelEl.classList.contains('W_ControlPanel--in-preview');
      const onClosePreview = () => {
        if (window.ContentPreview && typeof window.ContentPreview.closePreview === 'function') {
          window.ContentPreview.closePreview();
        }
      };
      closeBtn?.addEventListener('click', () => {
        if (isInPreview) onClosePreview();
      });
      maxBtn?.addEventListener('click', (e) => {
        e.preventDefault();
        if (isInPreview) {
          transferToGlobal(panelEl, onClosePreview);
          return;
        }
        panelEl.classList.toggle('is-maximized');
        maxBtn.setAttribute('aria-label', panelEl.classList.contains('is-maximized') ? 'Выйти из полноэкранного режима' : 'На весь экран');
      });
    }
  }

  function restoreGlobalVideo() {
    try {
      if (sessionStorage.getItem(STORAGE_KEY_VISIBLE) !== '1') return;
      const container = document.getElementById(GLOBAL_CONTAINER_ID);
      const panel = document.getElementById(GLOBAL_PANEL_ID);
      if (!container || !panel) return;
      container.style.display = 'block';
      container.setAttribute('aria-hidden', 'false');
      panel.removeAttribute('aria-hidden');
      panel.style.display = 'flex';
      panel.classList.add('is-visible');
      const saved = loadSavedRect();
      applyRect(panel, saved || getDefaultRect());
      const stateApplied = applySavedVideoState(panel);
      if (!stateApplied) {
        const root = panel.querySelector('[data-js-video-player-body]');
        const video = root?.querySelector('[data-js-video-player-src]');
        if (video && video.src) video.load();
      }
      initGlobalPanel(panel);
      globalVideoInited = true;
      attach(container);
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          container.classList.add('is-visible');
        });
      });
    } catch (e) {}
  }

  window.O_VideoPlayer = {
    attach,
    restoreGlobalVideo,
    setPlaylist
  };

  if (window.DomUtils) {
    window.DomUtils.ready(restoreGlobalVideo);
    window.DomUtils.turboLoad(restoreGlobalVideo);
  }
})();
