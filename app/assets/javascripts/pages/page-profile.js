(function() {
  const initProfile = function() {
    const avatarInput = document.getElementById('avatar-upload');
    if (!avatarInput) return;

    avatarInput.addEventListener('change', function() {
      if (this.files && this.files.length > 0) {
        const form = this.closest('form');
        if (form) {
          form.submit();
        }
      }
    });
  };

  window.DomUtils.ready(initProfile);
  window.DomUtils.turboLoad(initProfile);
})();

