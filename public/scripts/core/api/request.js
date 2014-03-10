(function() {
  define(['core/api/exception', 'config', 'cryptojs.hmac.sha256'], function(ApiException, app_config) {
    var ApiRequest;
    return ApiRequest = (function() {
      function ApiRequest(config, secure) {
        this.secure = secure != null ? secure : true;
        this.url = config.url || (function() {
          throw new Error('url parameter is missing');
        })();
        this.method = config.method || (function() {
          throw new Error('method parameter is missing');
        })();
        this.data = config.data || {};
        this._headers = config.headers || {};
        if (this.secure) {
          this.auth = config.auth || (function() {
            throw new Error('ApiAuth as auth parameter is missing');
          })();
        }
      }

      ApiRequest.prototype.headers = function() {
        var blob, headers, hmac, url;
        if (this.secure) {
          if (!this.auth.isValid()) {
            throw new ApiException(401, 'session_invalid');
          }
          blob = [];
          _.each(_.keys(this.data).sort(), function(key) {
            if (this.data.hasOwnProperty(key)) {
              return blob.push(("" + key + "=") + encodeURIComponent(this.data[key]));
            }
          });
          headers = {
            "St-Identifier": this.auth.identifier,
            "St-Timestamp": Math.round((+new Date()) / 1000)
          };
          hmac = CryptoJS.algo.HMAC.create(CryptoJS.algo.SHA256, this.auth.token);
          url = this.url.replace(app_config.api.base, '');
          hmac.update("" + this.method + ":");
          hmac.update("" + url + ":");
          hmac.update("" + headers['St-Timestamp'] + ":");
          hmac.update(blob.join("&"));
          headers["St-Hash"] = hmac.finalize().toString();
          _.extend(this._headers, headers);
        }
        return this._headers;
      };

      return ApiRequest;

    })();
  });

}).call(this);
