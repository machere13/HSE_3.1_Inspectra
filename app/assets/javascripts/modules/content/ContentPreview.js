(function() {
  const ContentPreview = {
    openPreview: function(type, url, card) {
      const preview = document.querySelector('.O_ContentPreview');
      if (!preview) return;
      const body = preview.querySelector('.O_ContentPreview-Body');
      if (!body) return;

      body.innerHTML = '';
      if (type === 'audio') {
        if (window.O_AudioPlayer && window.O_AudioPlayer.openInPreview && window.O_AudioPlayer.attach && window.O_AudioPlayer.setPlaylist) {
          const audioCards = document.querySelectorAll('.M_ContentCard[data-type="audio"]');
          const urls = Array.from(audioCards).map(function(c) { return c.getAttribute('data-preview-url') || ''; }).filter(Boolean);
          const currentIndex = (card && audioCards.length) ? Array.from(audioCards).indexOf(card) : 0;
          window.O_AudioPlayer.setPlaylist(urls, currentIndex >= 0 ? currentIndex : 0);
          const panel = window.O_AudioPlayer.openInPreview(url || '');
          if (panel) {
            body.appendChild(panel);
            window.O_AudioPlayer.attach(body);
            preview.classList.add('is-audio');
          }
        }
        preview.style.display = 'block';
        return;
      }

      let node;
      switch (type) {
        case 'image':
        case 'gif':
          node = document.createElement('img');
          node.src = url || '';
          break;
        case 'video':
          node = document.createElement('video');
          node.src = url || '';
          node.controls = true;
          break;
        case 'link':
          node = document.createElement('a');
          node.href = url || '#';
          node.target = '_blank';
          node.rel = 'noopener noreferrer';
          node.textContent = url || 'Open link';
          break;
        default:
          node = document.createElement('div');
          node.textContent = 'No preview available';
      }
      body.appendChild(node);
      preview.style.display = 'block';
    },

    closePreview: function() {
      const preview = document.querySelector('.O_ContentPreview');
      if (!preview) return;
      preview.classList.remove('is-audio');
      const body = preview.querySelector('.O_ContentPreview-Body');
      if (body) body.innerHTML = '';
      preview.style.display = 'none';
    },

    onCardClick: function(e) {
      const card = e.currentTarget;
      const type = (card.getAttribute('data-type') || 'content').toLowerCase();
      const url = card.getAttribute('data-preview-url') || '';
      if (type === 'article') return;
      this.openPreview(type, url, card);
    },

    bind: function() {
      document.querySelectorAll('.M_ContentCard').forEach(function(card) {
        const type = (card.getAttribute('data-type') || '').toLowerCase();
        if (type === 'article') return;
        card.addEventListener('click', this.onCardClick.bind(this));
      }.bind(this));

      const closeBtn = document.querySelector('.O_ContentPreview-Close');
      if (closeBtn) {
        closeBtn.addEventListener('click', this.closePreview.bind(this));
      }
    }
  };

  window.ContentPreview = ContentPreview;

  window.DomUtils.ready(function() {
    ContentPreview.bind();
  });
  window.DomUtils.turboLoad(function() {
    ContentPreview.bind();
  });
})();

