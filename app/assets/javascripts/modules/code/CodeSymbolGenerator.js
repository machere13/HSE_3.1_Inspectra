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

      const handleMouseMove = function(e) {
        const rect = container.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width;
        const y = (e.clientY - rect.top) / rect.height;

        const rotateX = -(y - 0.5) * 20;
        const rotateY = (x - 0.5) * 20;
        const rotateZ = -(x - 0.5) * 5;

        lines.forEach(function(line, index) {
          const lineY = (index / lines.length);
          const distanceFromCursor = Math.abs(y - lineY);
          const intensity = Math.max(0, 1 - distanceFromCursor * 1.5);
          
          const finalRotateX = rotateX * intensity;
          const finalRotateY = rotateY * intensity;
          const finalRotateZ = rotateZ * intensity * 0.5;

          line.style.setProperty('--mouse-rotate-x', finalRotateX + 'deg');
          line.style.setProperty('--mouse-rotate-y', finalRotateY + 'deg');
          line.style.setProperty('--mouse-rotate-z', finalRotateZ + 'deg');
        });
      };

      const handleMouseLeave = function() {
        lines.forEach(function(line) {
          line.style.setProperty('--mouse-rotate-x', '0deg');
          line.style.setProperty('--mouse-rotate-y', '0deg');
          line.style.setProperty('--mouse-rotate-z', '0deg');
        });
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

