(function() {
  function formatTime(s) {
    if (!Number.isFinite(s) || s < 0) return '00:00';
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return ((m < 10 ? '0' : '') + m) + ':' + ((sec < 10 ? '0' : '') + sec);
  }

  window.FormatTime = formatTime;
})();
