(function () {
  function pad(value) {
    return String(value).padStart(2, '0');
  }

  function bindCountdown(el) {
    if (el.dataset.countdownBound === '1') return;

    const expiresAtStr = el.getAttribute('data-expires-at');
    if (!expiresAtStr) return;

    const expiresAt = new Date(expiresAtStr);
    if (Number.isNaN(expiresAt.getTime())) return;

    const isTimerValue = el.classList.contains('timer-value');

    const update = () => {
      const now = new Date();
      const diffSeconds = Math.max(0, Math.floor((expiresAt.getTime() - now.getTime()) / 1000));

      const hours = Math.floor(diffSeconds / 3600);
      const minutes = Math.floor((diffSeconds % 3600) / 60);
      const seconds = diffSeconds % 60;

      const timeStr = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
      el.textContent = isTimerValue ? timeStr : `TIME_LEFT: ${timeStr}`;

      if (diffSeconds === 0) {
        clearInterval(intervalId);
      }
    };

    update();
    const intervalId = window.setInterval(update, 1000);

    el.dataset.countdownBound = '1';
    el.dataset.countdownIntervalId = String(intervalId);
  }

  function initCountdowns() {
    document.querySelectorAll('[data-countdown][data-expires-at]').forEach(bindCountdown);
  }

  function teardownCountdowns() {
    document.querySelectorAll('[data-countdown-interval-id]').forEach((el) => {
      const id = Number(el.dataset.countdownIntervalId);
      if (!Number.isNaN(id)) {
        window.clearInterval(id);
      }
      delete el.dataset.countdownIntervalId;
      delete el.dataset.countdownBound;
    });
  }

  document.addEventListener('DOMContentLoaded', initCountdowns);
  document.addEventListener('turbo:load', initCountdowns);
  document.addEventListener('turbo:before-cache', teardownCountdowns);
})();
