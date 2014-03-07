(function() {
  define(['core/container', 'core/core', 'apps/squareteam', 'config'], function(Container, Core, Squareteam, Config) {
    var container;
    container = new Container(true);
    Core.injectTo(container);
    container.set('config', function() {
      return Config;
    });
    container.set('api.extras', function(services) {
      var _publish;
      _publish = {};
      _.each({
        "read": "GET",
        "destroy": "DELETE",
        "update": "PUT",
        "create": "POST"
      }, function(http_method, helper) {
        var _this = this;
        return _publish[helper] = function(url, data, secure) {
          var config, request;
          if (data == null) {
            data = null;
          }
          if (secure == null) {
            secure = true;
          }
          config = {
            url: services.get('config').api.url + url,
            data: data,
            method: http_method
          };
          if (secure) {
            if (!services.get('core.session').isAuthenticated()) {
              throw new Error('session.invalid');
            }
            config.secure = true;
            config.auth = services.get('core.session').auth;
          }
          request = new (services.get('core.api').Request)(config, secure);
          return services.get('core.api').Api.proceed(request);
        };
      });
      return _publish;
    });
    return container.bound(function(services) {
      var app_configure,
        _this = this;
      app_configure = (new Squareteam(services)).configure({
        "router": {
          "default_route": "/home",
          "default_configurators": {
            acl: {
              anonymous: false,
              ifNot: '/login'
            }
          }
        }
      });
      app_configure.then(function(app) {
        services.set('app', app);
        console.info("app booted");
        app.configurators();
        app.routes();
        return app.router.boot();
      });
      return app_configure["catch"](function(e) {
        return console.error("App error : " + e);
      });
    });
  });

}).call(this);
