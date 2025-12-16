(function() {
  window.MathUtils = {
    randomInt: function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    },

    distance: function(x1, y1, x2, y2) {
      const dx = x2 - x1;
      const dy = y2 - y1;
      return Math.sqrt(dx * dx + dy * dy);
    },

    clamp: function(value, min, max) {
      return Math.max(min, Math.min(max, value));
    }
  };
})();

