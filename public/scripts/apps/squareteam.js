(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['when'], function(When) {
    var SquareteamApp;
    return SquareteamApp = (function() {
      function SquareteamApp(container) {
        this.container = container;
        this.configure = __bind(this.configure, this);
      }

      SquareteamApp.prototype.configure = function(config) {
        var defer,
          _this = this;
        defer = When.defer();
        this.router = this.container.get('core.router')(config.router);
        if ((config.session != null) && config.session.autoload) {
          this.container.get('core.session').restore().done(function(session) {
            _this.container.set('session', session);
            return defer.resolver.resolve(_this);
          }, function(e) {
            _this.container.set("session", new (_this.container.get('core.session')).Anonymous());
            if (e.toString() === 'session.invalid') {
              _this.router.setFlash('Session expired, please login');
            }
            return defer.resolver.resolve(_this);
          });
        } else {
          this.container.set("session", new (this.container.get('core.session')).Anonymous());
          defer.resolver.resolve(this);
        }
        return defer.promise;
      };

      SquareteamApp.prototype.configurators = function() {
        return this.router.configurator('acl', function(services, route, config, resolve, reject) {
          var e;
          try {
            if (!config.anonymous && !services.get('session').isAuthenticated()) {
              reject({
                flash: 'anonymous not authorized'
              });
              if ((config.ifNot != null) && route !== config.ifNot) {
                return services.get('app').router.navigate(config.ifNot, {
                  trigger: true,
                  replace: true
                });
              }
            } else {
              return resolve();
            }
          } catch (_error) {
            e = _error;
            return console.dir(e);
          }
        });
      };

      SquareteamApp.prototype.routes = function() {
        var _this = this;
        this.router.route(['knowledge', 'knowledge/*path'], 'knowledge', function(path, services) {
          return console.log('knowledge');
        });
        this.router.route('login', 'login', function() {
          return require(['apps/public/login'], function(login) {
            return login(_this.container);
          });
        }, {
          acl: false
        });
        this.router.route('register', 'register', function() {
          return require(['apps/public/register'], function(register) {
            return register(_this.container);
          });
        }, {
          acl: false
        });
        return this.router.route('home', 'home', function() {
          console.log('home');
          return $(".squareteam-layout").html("<h1>Home</h1><p>Hi " + (_this.container.get('session').user.get('name')) + "</p>");
        });
      };

      return SquareteamApp;

    })();
  });

}).call(this);
