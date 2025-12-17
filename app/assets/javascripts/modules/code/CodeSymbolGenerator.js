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

    getRandomItem: function(array) {
      return array[Math.floor(Math.random() * array.length)];
    },

    generateLine: function(minLength, maxLength) {
      const length = Math.floor(Math.random() * (maxLength - minLength + 1)) + minLength;
      const parts = [];
      let currentLength = 0;
      let useWord = Math.random() > 0.3;

      while (currentLength < length) {
        if (useWord && this.codeWords.length > 0) {
          const word = this.getRandomItem(this.codeWords);
          if (currentLength + word.length <= length) {
            parts.push(word);
            currentLength += word.length;
            useWord = false;
          } else {
            break;
          }
        } else {
          const symbol = this.getRandomItem(this.symbols);
          parts.push(symbol);
          currentLength += symbol.length;
          useWord = Math.random() > 0.4;
        }
      }

      return parts.join('');
    },

    generateCodeBlock: function(container, linesCount, minLineLength, maxLineLength) {
      if (!container) return;

      let backgroundElement = container.querySelector('.CodeSymbolGenerator-Background');
      if (!backgroundElement) {
        backgroundElement = document.createElement('div');
        backgroundElement.className = 'CodeSymbolGenerator-Background';
        container.appendChild(backgroundElement);
      }

      const fragment = document.createDocumentFragment();
      
      for (let i = 0; i < linesCount; i++) {
        const line = document.createElement('div');
        line.className = 'CodeSymbolGenerator-Line';
        line.textContent = this.generateLine(minLineLength, maxLineLength);
        fragment.appendChild(line);
      }

      backgroundElement.innerHTML = '';
      backgroundElement.appendChild(fragment);
    },

    init: function() {
      const containers = document.querySelectorAll('.O_CardWeekCurrent-Body');
      
      containers.forEach(function(container) {
        if (container.dataset.codeGenerated === '1') return;
        
        const rect = container.getBoundingClientRect();
        const estimatedLines = Math.floor(rect.height / 80) + 2;
        const minLineLength = 20;
        const maxLineLength = 50;

        CodeSymbolGenerator.generateCodeBlock(container, estimatedLines, minLineLength, maxLineLength);
        container.dataset.codeGenerated = '1';
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

