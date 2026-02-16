(() => {
  const formatTime = (s) => {
    if (!Number.isFinite(s) || s < 0) return '00:00';
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return `${(m < 10 ? '0' : '') + m}:${(sec < 10 ? '0' : '') + sec}`;
  };

  function attach(container) {
    const root = container.querySelector('[data-js-video-player-body]');
    if (!root) return;
    const video = root.querySelector('[data-js-video-player-src]');
    const playCenter = root.querySelector('.O_VideoPlayer-PlayCenter');
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
    if (!video) return;

    const updateTime = () => { if (timeEl) timeEl.textContent = formatTime(video.currentTime); };
    const updateDuration = () => { if (durationEl) durationEl.textContent = formatTime(video.duration); };
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
    video.addEventListener('play', () => { if (playCenter) playCenter.classList.add('is-hidden'); });
    video.addEventListener('pause', () => { if (playCenter) playCenter.classList.remove('is-hidden'); });

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

    if (fullscreenBtn) {
      fullscreenBtn.addEventListener('click', () => {
        const panel = root.closest('.W_ControlPanel');
        if (!panel) return;
        if (!document.fullscreenElement) {
          panel.requestFullscreen().catch(() => {});
        } else {
          document.exitFullscreen();
        }
      });
    }

    const panelEl = container.querySelector('.W_ControlPanel');
    if (panelEl) {
      const closeBtn = panelEl.querySelector('[data-js-console-close]');
      const maxBtn = panelEl.querySelector('[data-js-console-maximize]');
      closeBtn?.addEventListener('click', () => {
        if (window.ContentPreview && typeof window.ContentPreview.closePreview === 'function') {
          window.ContentPreview.closePreview();
        }
      });
      maxBtn?.addEventListener('click', (e) => {
        e.preventDefault();
        panelEl.classList.toggle('is-maximized');
        maxBtn.setAttribute('aria-label', panelEl.classList.contains('is-maximized') ? 'Выйти из полноэкранного режима' : 'На весь экран');
      });
    }
  }

  window.O_VideoPlayer = {
    attach
  };
})();
