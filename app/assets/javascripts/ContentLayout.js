(function(){
  function randomInt(min, max){
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  function placeRandom(){
    const container = document.querySelector('.PageWeek-Content');
    if (!container) return;
    const canvasContainer = container.querySelector('.PageWeek-Content-Canvas');
    if (canvasContainer) return;
    container.style.position = 'relative';

    const items = Array.from(container.querySelectorAll('.PageWeek-Content-Item'))
      .filter((n) => n.querySelector('.M_ContentCard'));

    items.forEach((item) => {
      if (item.dataset.placed === '1') return;
      item.style.position = 'absolute';

      const rect = container.getBoundingClientRect();
      const itemRect = item.getBoundingClientRect();

      const maxLeft = Math.max(0, rect.width - itemRect.width - 10);
      const maxTop = Math.max(0, rect.height - itemRect.height - 10);

      const left = randomInt(0, maxLeft);
      const top = randomInt(0, maxTop);

      item.style.left = left + 'px';
      item.style.top = top + 'px';
      item.dataset.placed = '1';
    });
  }

  document.addEventListener('DOMContentLoaded', placeRandom);
  document.addEventListener('turbo:load', placeRandom);
})();


