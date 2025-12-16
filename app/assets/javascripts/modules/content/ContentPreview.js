(function() {
  const ContentPreview = {
    openPreview: function(type, url) {
      const preview = document.querySelector('.O_ContentPreview');
      if (!preview) return;
      const body = preview.querySelector('.O_ContentPreview-Body');
      if (!body) return;

      body.innerHTML = '';
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
        case 'audio':
          node = document.createElement('audio');
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
      const body = preview.querySelector('.O_ContentPreview-Body');
      if (body) body.innerHTML = '';
      preview.style.display = 'none';
    },

    onCardClick: function(e) {
      const card = e.currentTarget;
      const type = (card.getAttribute('data-type') || 'content').toLowerCase();
      const url = card.getAttribute('data-preview-url') || '';
      if (type === 'article') return;
      this.openPreview(type, url);
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

