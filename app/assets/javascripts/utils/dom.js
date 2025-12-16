(function() {
  window.DomUtils = {
    ready: function(callback) {
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', callback);
      } else {
        callback();
      }
    },

    turboLoad: function(callback) {
      document.addEventListener('turbo:load', callback);
    },

    query: function(selector, context) {
      return (context || document).querySelector(selector);
    },

    queryAll: function(selector, context) {
      return Array.from((context || document).querySelectorAll(selector));
    }
  };
})();

