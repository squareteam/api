(function() {
  define([], function() {
    var ApiException;
    return ApiException = (function() {
      function ApiException(code, reason) {
        this.code = code;
        this.reason = reason;
      }

      ApiException.prototype.toString = function() {
        return "ApiError(" + this.code + "): " + this.reason;
      };

      ApiException.prototype.getReason = function() {
        return this.reason;
      };

      return ApiException;

    })();
  });

}).call(this);
