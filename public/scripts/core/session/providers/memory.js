(function() {
  define(["core/api/auth"], function(ApiAuth) {
    var ProviderMemory, auth;
    auth = null;
    ProviderMemory = (function() {
      function ProviderMemory() {}

      ProviderMemory.prototype.retrieve = function() {
        if (!ProviderMemory.empty()) {
          return auth;
        } else {
          return null;
        }
      };

      ProviderMemory.prototype.store = function(api_auth) {
        if (api_auth.isValid()) {
          return auth = api_auth;
        } else {
          throw new Error("ApiAuth invalid");
        }
      };

      ProviderMemory.prototype.destroy = function() {
        return auth = null;
      };

      return ProviderMemory;

    })();
    ProviderMemory.empty = function() {
      return true;
    };
    return ProviderMemory;
  });

}).call(this);
