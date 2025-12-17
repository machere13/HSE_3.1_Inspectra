(function() {
  const CodeSymbolGenerator = {
    codeWords: [
      'function', 'const', 'let', 'var', 'return', 'if', 'else', 'for', 'while',
      'class', 'extends', 'import', 'export', 'async', 'await', 'promise',
      'array', 'object', 'string', 'number', 'boolean', 'null', 'undefined',
      'true', 'false', 'this', 'super', 'new', 'typeof', 'instanceof',
      'try', 'catch', 'throw', 'finally', 'break', 'continue', 'switch',
      'case', 'default', 'do', 'void', 'delete', 'in', 'of', 'with',
      'prototype', 'constructor', 'method', 'property', 'callback', 'handler',
      'event', 'listener', 'element', 'document', 'window', 'console', 'log',
      'querySelector', 'addEventListener', 'getElementById', 'innerHTML',
      'setTimeout', 'setInterval', 'requestAnimationFrame', 'fetch', 'then',
      'catch', 'json', 'parse', 'stringify', 'push', 'pop', 'shift', 'unshift',
      'map', 'filter', 'reduce', 'forEach', 'find', 'some', 'every', 'includes',
      'length', 'indexOf', 'slice', 'splice', 'join', 'split', 'replace',
      'toUpperCase', 'toLowerCase', 'trim', 'substring', 'substr', 'charAt',
      'Math', 'random', 'floor', 'ceil', 'round', 'max', 'min', 'abs', 'sqrt',
      'Date', 'now', 'getTime', 'getFullYear', 'getMonth', 'getDate',
      'RegExp', 'test', 'match', 'exec', 'replace', 'search',
      'Error', 'TypeError', 'ReferenceError', 'SyntaxError',
      'localStorage', 'sessionStorage', 'getItem', 'setItem', 'removeItem',
      'XMLHttpRequest', 'open', 'send', 'response', 'status', 'readyState',
      'addClass', 'removeClass', 'toggleClass', 'hasClass', 'attr', 'data',
      'css', 'width', 'height', 'display', 'position', 'top', 'left', 'right',
      'bottom', 'margin', 'padding', 'border', 'background', 'color', 'font',
      'opacity', 'transform', 'transition', 'animation', 'keyframes',
      'flex', 'grid', 'column', 'row', 'wrap', 'justify', 'align', 'center',
      'start', 'end', 'between', 'around', 'evenly', 'stretch', 'baseline',
      'block', 'inline', 'none', 'hidden', 'visible', 'absolute', 'relative',
      'fixed', 'static', 'sticky', 'inherit', 'initial', 'unset', 'auto'
    ],

    symbols: [';', '$', '%', '#', '@', '&', '*', '(', ')', '{', '}', '[', ']', '=', '+', '-', '/', '\\', '|', '<', '>', '?', ':', '!', '~', '^', '`', '"', "'", ',', '.'],

    seed: 0,
    seedRandom: function() {
      this.seed = (this.seed * 9301 + 49297) % 233280;
      return this.seed / 233280;
    },

    setSeed: function(seed) {
      this.seed = seed;
    },

    getRandomItem: function(array) {
      return array[Math.floor(this.seedRandom() * array.length)];
    },

    generateLine: function(minLength, maxLength) {
      const length = Math.floor(this.seedRandom() * (maxLength - minLength + 1)) + minLength;
      const parts = [];
      let currentLength = 0;
      let useWord = this.seedRandom() > 0.3;

      while (currentLength < length) {
        const shouldHighlight = this.seedRandom() < 0.15;
        
        if (useWord && this.codeWords.length > 0) {
          const word = this.getRandomItem(this.codeWords);
          if (currentLength + word.length <= length) {
            if (shouldHighlight) {
              parts.push('<span class="CodeSymbolGenerator-Highlight">' + word + '</span>');
            } else {
              parts.push(word);
            }
            currentLength += word.length;
            useWord = false;
          } else {
            break;
          }
        } else {
          const symbol = this.getRandomItem(this.symbols);
          if (shouldHighlight) {
            parts.push('<span class="CodeSymbolGenerator-Highlight">' + symbol + '</span>');
          } else {
            parts.push(symbol);
          }
          currentLength += symbol.length;
          useWord = this.seedRandom() > 0.4;
        }
      }

      return parts.join('');
    },

    generateCodeBlock: function(container, weekNumber, linesCount, minLineLength, maxLineLength) {
      if (!container) return;

      let backgroundElement = container.querySelector('.CodeSymbolGenerator-Background');
      if (backgroundElement && backgroundElement.dataset.generated === '1') {
        return;
      }

      if (!backgroundElement) {
        backgroundElement = document.createElement('div');
        backgroundElement.className = 'CodeSymbolGenerator-Background';
        container.appendChild(backgroundElement);
      }

      this.setSeed(weekNumber * 1000 + 12345);

      const fragment = document.createDocumentFragment();
      
      for (let i = 0; i < linesCount; i++) {
        const line = document.createElement('div');
        line.className = 'CodeSymbolGenerator-Line';
        line.innerHTML = this.generateLine(minLineLength, maxLineLength);
        fragment.appendChild(line);
      }

      backgroundElement.innerHTML = '';
      backgroundElement.appendChild(fragment);
      backgroundElement.dataset.generated = '1';
    },

    setupMouseInteraction: function(container) {
      const backgroundElement = container.querySelector('.CodeSymbolGenerator-Background');
      if (!backgroundElement) return;

      const lines = backgroundElement.querySelectorAll('.CodeSymbolGenerator-Line');
      if (lines.length === 0) return;

      let isMouseInside = false;
      let animationFrameId = null;
      let mouseX = 0.5;
      let mouseY = 0.5;

      const updateValues = function() {
        let needsUpdate = false;

        lines.forEach(function(line, index) {
          const currentX = parseFloat(line.style.getPropertyValue('--mouse-rotate-x') || '0');
          const currentY = parseFloat(line.style.getPropertyValue('--mouse-rotate-y') || '0');
          const currentZ = parseFloat(line.style.getPropertyValue('--mouse-rotate-z') || '0');

          if (isMouseInside) {
            const lineY = (index / lines.length);
            const distanceFromCursor = Math.abs(mouseY - lineY);
            const intensity = Math.max(0, 1 - distanceFromCursor * 1.5);
            
            const rotateX = -(mouseY - 0.5) * 20;
            const rotateY = (mouseX - 0.5) * 20;
            const rotateZ = -(mouseX - 0.5) * 5;
            
            const targetX = rotateX * intensity;
            const targetY = rotateY * intensity;
            const targetZ = rotateZ * intensity * 0.5;

            const diffX = Math.abs(targetX - currentX);
            const diffY = Math.abs(targetY - currentY);
            const diffZ = Math.abs(targetZ - currentZ);

            if (diffX > 0.1 || diffY > 0.1 || diffZ > 0.1) {
              needsUpdate = true;
              const newX = currentX + (targetX - currentX) * 0.2;
              const newY = currentY + (targetY - currentY) * 0.2;
              const newZ = currentZ + (targetZ - currentZ) * 0.2;
              line.style.setProperty('--mouse-rotate-x', newX + 'deg');
              line.style.setProperty('--mouse-rotate-y', newY + 'deg');
              line.style.setProperty('--mouse-rotate-z', newZ + 'deg');
            } else {
              line.style.setProperty('--mouse-rotate-x', targetX + 'deg');
              line.style.setProperty('--mouse-rotate-y', targetY + 'deg');
              line.style.setProperty('--mouse-rotate-z', targetZ + 'deg');
            }
          } else {
            if (Math.abs(currentX) > 0.1 || Math.abs(currentY) > 0.1 || Math.abs(currentZ) > 0.1) {
              needsUpdate = true;
              const newX = currentX * 0.85;
              const newY = currentY * 0.85;
              const newZ = currentZ * 0.85;
              line.style.setProperty('--mouse-rotate-x', newX + 'deg');
              line.style.setProperty('--mouse-rotate-y', newY + 'deg');
              line.style.setProperty('--mouse-rotate-z', newZ + 'deg');
            } else {
              line.style.setProperty('--mouse-rotate-x', '0deg');
              line.style.setProperty('--mouse-rotate-y', '0deg');
              line.style.setProperty('--mouse-rotate-z', '0deg');
            }
          }
        });

        if (needsUpdate) {
          animationFrameId = requestAnimationFrame(updateValues);
        } else {
          animationFrameId = null;
        }
      };

      const handleMouseMove = function(e) {
        const rect = container.getBoundingClientRect();
        mouseX = (e.clientX - rect.left) / rect.width;
        mouseY = (e.clientY - rect.top) / rect.height;

        if (!isMouseInside) {
          isMouseInside = true;
        }

        if (!animationFrameId) {
          animationFrameId = requestAnimationFrame(updateValues);
        }
      };

      const handleMouseLeave = function() {
        isMouseInside = false;
        if (!animationFrameId) {
          animationFrameId = requestAnimationFrame(updateValues);
        }
      };

      container.addEventListener('mousemove', handleMouseMove);
      container.addEventListener('mouseleave', handleMouseLeave);
    },

    init: function() {
      const containers = document.querySelectorAll('.O_CardWeekCurrent-Body');
      
      containers.forEach(function(container) {
        if (container.dataset.codeGenerated === '1') {
          CodeSymbolGenerator.setupMouseInteraction(container);
          return;
        }
        
        const weekNumber = parseInt(container.getAttribute('data-week-number'), 10);
        if (isNaN(weekNumber)) return;

        const rect = container.getBoundingClientRect();
        const estimatedLines = Math.floor(rect.height / 80) + 2;
        const minLineLength = 50;
        const maxLineLength = 120;

        CodeSymbolGenerator.generateCodeBlock(container, weekNumber, estimatedLines, minLineLength, maxLineLength);
        container.dataset.codeGenerated = '1';
        
        CodeSymbolGenerator.setupMouseInteraction(container);
      });
    }
  };

  window.CodeSymbolGenerator = CodeSymbolGenerator;

  window.DomUtils.ready(function() {
    CodeSymbolGenerator.init();
  });
  window.DomUtils.turboLoad(function() {
    CodeSymbolGenerator.init();
  });
})();

