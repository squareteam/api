(function() {
  define(['when', 'core/api/exception', 'core/api/request', 'core/api/auth'], function(When, ApiException, ApiRequest, ApiAuth) {
    var Api;
    Api = (function() {
      function Api() {}

      Api.proceed = function(api_request) {
        var defer;
        defer = When.defer();
        $.ajax(api_request.url, {
          context: this,
          dataType: 'json',
          data: api_request.data,
          headers: api_request.headers(),
          type: api_request.method,
          error: function(jqXHR, textStatus, error) {
            switch (textStatus) {
              case "error":
                return defer.resolver.reject(new ApiException(jqXHR.status, jqXHR.responseText));
              case "parsererror":
                return defer.resolver.reject(new ApiException(500, "response.parse_error"));
            }
          },
          success: function(data, textStatus) {
            return Api._handleResponse(data, defer.resolver);
          }
        });
        return defer.promise;
      };

      Api._handleResponse = function(response, resolver) {
        if (response.data == null) {
          return resolver.reject(new ApiException("response.malformed"));
        } else if ((response.error != null) && response.error.length) {
          return resolver.reject(new ApiException("api.error", response.error));
        } else {
          return resolver.resolve(response.data);
        }
      };

      return Api;

    })();
    return {
      Api: Api,
      Exception: ApiException,
      Request: ApiRequest,
      Auth: ApiAuth
    };
  });

}).call(this);
