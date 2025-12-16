(function() {
  const HomeCountdown = {
    pad: function(value) {
      return String(value).padStart(2, '0');
    },

    bindCountdown: function(el) {
      if (el.dataset.countdownBound === '1') return;

      const expiresAtStr = el.getAttribute('data-expires-at');
      if (!expiresAtStr) return;

      const expiresAt = new Date(expiresAtStr);
      if (Number.isNaN(expiresAt.getTime())) return;

      const isTimerValue = el.classList.contains('timer-value');

      const update = function() {
        const now = new Date();
        const diffSeconds = Math.max(0, Math.floor((expiresAt.getTime() - now.getTime()) / 1000));

        const hours = Math.floor(diffSeconds / 3600);
        const minutes = Math.floor((diffSeconds % 3600) / 60);
        const seconds = diffSeconds % 60;

        const timeStr = this.pad(hours) + ':' + this.pad(minutes) + ':' + this.pad(seconds);
        el.textContent = isTimerValue ? timeStr : 'TIME_LEFT: ' + timeStr;

        if (diffSeconds === 0) {
          clearInterval(intervalId);
        }
      }.bind(this);

      update();
      const intervalId = window.setInterval(update, 1000);

      el.dataset.countdownBound = '1';
      el.dataset.countdownIntervalId = String(intervalId);
    },

    initCountdowns: function() {
      document.querySelectorAll('[data-countdown][data-expires-at]').forEach(function(el) {
        this.bindCountdown(el);
      }.bind(this));
    },

    teardownCountdowns: function() {
      document.querySelectorAll('[data-countdown-interval-id]').forEach(function(el) {
        const id = Number(el.dataset.countdownIntervalId);
        if (!Number.isNaN(id)) {
          window.clearInterval(id);
        }
        delete el.dataset.countdownIntervalId;
        delete el.dataset.countdownBound;
      });
    }
  };

  window.HomeCountdown = HomeCountdown;

  window.DomUtils.ready(function() {
    HomeCountdown.initCountdowns();
  });
  window.DomUtils.turboLoad(function() {
    HomeCountdown.initCountdowns();
  });
  document.addEventListener('turbo:before-cache', function() {
    HomeCountdown.teardownCountdowns();
  });
})();

