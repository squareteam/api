(function() {
  define(['when', 'core/api/exception', 'core/api/request', 'core/api/auth'], function(When, ApiException, ApiRequest, ApiAuth) {
    var Api, ApiErrors;
    ApiErrors = (function() {
      function ApiErrors(code, errors) {
        this.code = code;
        this.errors = errors;
      }

      ApiErrors.prototype.toString = function() {
        return "ApiError(" + this.code + "): " + this.errors;
      };

      ApiErrors.prototype.getErrors = function() {
        return this.errors;
      };

      ApiErrors.prototype.getError = function(at) {
        if (this.errors[at] != null) {
          return this.errors[at];
        } else {
          return null;
        }
      };

      return ApiErrors;

    })();
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
            var e, json;
            switch (textStatus) {
              case "error":
                json = false;
                try {
                  json = $.parseJSON(jqXHR.responseText);
                } catch (_error) {
                  e = _error;
                  defer.resolver.reject(new ApiException(jqXHR.status, jqXHR.responseText));
                }
                if (json && (json.errors != null) && json.errors.length) {
                  return defer.resolver.reject(new ApiErrors("api.error", json.errors));
                } else {
                  return defer.resolver.reject(new ApiException(jqXHR.status, jqXHR.responseText));
                }
                break;
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
        } else if ((response.errors != null) && response.errors.length) {
          return resolver.reject(new ApiErrors("api.error", response.errors));
        } else {
          return resolver.resolve(response.data);
        }
      };

      return Api;

    })();
    return {
      Api: Api,
      Exception: ApiException,
      Error: ApiErrors,
      Request: ApiRequest,
      Auth: ApiAuth
    };
  });

}).call(this);
