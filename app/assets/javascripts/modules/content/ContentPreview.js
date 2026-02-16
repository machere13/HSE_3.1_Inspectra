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
          const seen = new Set();
          const urls = [];
          const titles = [];
          for (let i = 0; i < audioCards.length; i++) {
            const c = audioCards[i];
            const u = (c.getAttribute('data-preview-url') || '').trim();
            if (u && !seen.has(u)) {
              seen.add(u);
              urls.push(u);
              const titleEl = c.querySelector('.M_ContentCard-Title');
              titles.push(titleEl ? titleEl.textContent.trim() : '');
            }
          }
          const currentUrl = (card && card.getAttribute('data-preview-url')) ? card.getAttribute('data-preview-url').trim() : (url || '').trim();
          let currentIndex = urls.length && currentUrl ? urls.indexOf(currentUrl) : 0;
          if (currentIndex < 0) currentIndex = 0;
          window.O_AudioPlayer.setPlaylist(urls, currentIndex, titles);
          const panel = window.O_AudioPlayer.openInPreview(url || '');
          if (panel) {
            body.appendChild(panel);
            window.O_AudioPlayer.attach(body);
            preview.classList.add('is-audio');
          }
        }
        preview.style.display = 'block';
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            preview.classList.add('is-visible');
          });
        });
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
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          preview.classList.add('is-visible');
        });
      });
    },

    closePreview: function() {
      const preview = document.querySelector('.O_ContentPreview');
      if (!preview) return;
      preview.classList.remove('is-audio');
      preview.classList.remove('is-visible');
      const body = preview.querySelector('.O_ContentPreview-Body');
      const transitionMs = 280;
      setTimeout(() => {
        if (body) body.innerHTML = '';
        preview.style.display = 'none';
      }, transitionMs);
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

