(function() {
  const TokenGenerator = {
    generate: function(length) {
      length = length || 16;
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      let token = '';
      for (let i = 0; i < length; i++) {
        token += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      return token;
    },
    
    generateSecure: function(length) {
      length = length || 16;
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
      let token = '';
      const array = new Uint8Array(length);
      window.crypto.getRandomValues(array);
      for (let i = 0; i < length; i++) {
        token += chars.charAt(array[i] % chars.length);
      }
      return token;
    }
  };
  
  window.TokenGenerator = TokenGenerator;
})();

