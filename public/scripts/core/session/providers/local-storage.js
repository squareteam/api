(function() {
  define(["core/api/auth"], function(ApiAuth) {
    var ProviderLocalStorage;
    ProviderLocalStorage = (function() {
      function ProviderLocalStorage() {}

      ProviderLocalStorage.prototype.retrieve = function() {
        var values;
        if (!ProviderLocalStorage.empty()) {
          values = localStorage.getItem("ST_SESSION").split(':');
          return new ApiAuth(values[0], values[1]);
        } else {
          return null;
        }
      };

      ProviderLocalStorage.prototype.store = function(api_auth) {
        if (api_auth.isValid()) {
          return localStorage.setItem("ST_SESSION", "" + api_auth.identifier + ":" + api_auth.token);
        } else {
          throw new Error("ApiAuth invalid");
        }
      };

      ProviderLocalStorage.prototype.destroy = function() {
        return localStorage.removeItem("ST_SESSION");
      };

      return ProviderLocalStorage;

    })();
    ProviderLocalStorage.empty = function() {
      return localStorage.getItem("ST_SESSION") === null;
    };
    return ProviderLocalStorage;
  });

}).call(this);
