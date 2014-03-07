(function() {
  define(["core/api/auth"], function(ApiAuth) {
    var ProviderCookie;
    ProviderCookie = (function() {
      function ProviderCookie() {}

      ProviderCookie.prototype.retrieve = function() {
        var auth, values;
        if (!ProviderCookie.empty()) {
          values = $.cookies("ST_SESSION");
          auth = new ApiAuth(values[0], values[1]);
          if (!auth.isValid()) {
            throw new Error("ApiAuth invalid");
          } else {
            return auth;
          }
        } else {
          return null;
        }
      };

      ProviderCookie.prototype.store = function(api_auth) {
        if (api_auth.isValid()) {
          return $.cookies("ST_SESSION", "" + api_auth.identifier + ":" + api_auth.token);
        } else {
          throw new Error("ApiAuth invalid");
        }
      };

      ProviderCookie.prototype.destroy = function() {
        return $.removeCookie("ST_SESSION");
      };

      return ProviderCookie;

    })();
    ProviderCookie.empty = function() {
      return typeof ($.cookies("ST_SESSION")) === "undefined";
    };
    return ProviderCookie;
  });

}).call(this);
