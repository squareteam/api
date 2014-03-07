(function() {
  define([], function() {
    var ApiAuth;
    return ApiAuth = (function() {
      function ApiAuth(identifier, token) {
        this.identifier = identifier;
        this.token = token;
      }

      ApiAuth.prototype.isValid = function() {
        return (this.identifier != null) && (this.token != null);
      };

      return ApiAuth;

    })();
  });

}).call(this);
