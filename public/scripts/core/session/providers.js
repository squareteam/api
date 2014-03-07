(function() {
  define(['core/session/providers/cookies', 'core/session/providers/local-storage', 'core/session/providers/memory'], function(ProviderCookie, ProviderLocalStorage, ProviderMemory) {
    return {
      "Cookies": ProviderCookie,
      "LocalStorage": ProviderLocalStorage,
      "Memory": ProviderMemory
    };
  });

}).call(this);
