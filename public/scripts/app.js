(function() {
  define(['core/container', 'core/core', 'apps/squareteam', 'config', "when"], function(Container, Core, Squareteam, Config, When) {
    var ApiExtras, ctx,
      _this = this;
    ctx = di.createContext();
    window.ctx = ctx;
    ctx.register('config').object(Config);
    Core.injectTo(ctx);
    ctx.register('session').object(new ctx.get('coreSession').Anonymous);
    ApiExtras = (function() {
      function ApiExtras() {
        this.dependencies = "coreApi,config,app";
      }

      ApiExtras.prototype.ready = function() {
        var _this = this;
        return _.each({
          "read": "GET",
          "destroy": "DELETE",
          "update": "PUT",
          "create": "POST"
        }, function(http_method, helper) {
          return _this[helper] = function(url, data, secure) {
            var config, deferError, request;
            if (data == null) {
              data = null;
            }
            if (secure == null) {
              secure = true;
            }
            config = {
              url: _this.config.api.base + url,
              data: data,
              method: http_method
            };
            if (secure) {
              if (!_this.app.session.isAuthenticated()) {
                deferError = When.defer();
                deferError.resolver.reject();
                return deferError.promise;
              }
              config.secure = true;
              config.auth = _this.app.session.auth;
            }
            request = new _this.coreApi.Request(config, secure);
            return _this.coreApi.Api.proceed(request);
          };
        });
      };

      return ApiExtras;

    })();
    ctx.register("apiExtras", ApiExtras);
    ctx.register("app", Squareteam);
    ctx.get('app').on('ready', function() {
      var app_configure;
      ctx.get('app').setContext(ctx);
      app_configure = ctx.get('app').configure({
        "router": {
          "default_route": "/home",
          "default_configurators": {
            acl: {
              anonymous: false,
              ifNot: '/login'
            }
          }
        },
        "session": {
          "autoload": true
        }
      });
      app_configure.then(function(app) {
        app.configurators();
        app.routes();
        return app.router.boot();
      });
      return app_configure["catch"](function(e) {
        return console.error("App error : " + e);
      });
    });
    return ctx.initialize();
  });

}).call(this);
