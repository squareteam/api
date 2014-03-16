(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['when'], function(When) {
    var SquareteamApp;
    SquareteamApp = (function() {
      function SquareteamApp() {
        this.configure = __bind(this.configure, this);
        this.dependencies = 'coreRouter,coreSession';
      }

      SquareteamApp.prototype.ready = function() {
        return this.trigger('ready');
      };

      SquareteamApp.prototype.setContext = function(ctx) {
        return this.ctx = ctx;
      };

      SquareteamApp.prototype.configure = function(config) {
        var defer,
          _this = this;
        defer = When.defer();
        this.router = new this.coreRouter(config.router != null ? config.router : {});
        if ((config.session != null) && config.session.autoload) {
          this.coreSession.restore().done(function(session) {
            _this.session = session;
            return defer.resolver.resolve(_this);
          }, function(e) {
            _this.session = new _this.coreSession.Anonymous();
            if (e.toString() === 'session.invalid') {
              _this.router.setFlash('Session expired, please login');
            }
            return defer.resolver.resolve(_this);
          });
        } else {
          this.session = new this.coreSession.Anonymous();
          defer.resolver.resolve(this);
        }
        return defer.promise;
      };

      SquareteamApp.prototype.configurators = function() {
        this.router.setApp(this);
        return this.router.configurator('acl', function(app, route, config, resolve, reject) {
          if (!config.anonymous && !app.session.isAuthenticated()) {
            app.router.setFlash('Anonymous not authorized, please login');
            reject();
            if ((config.ifNot != null) && route !== config.ifNot) {
              return app.router.navigate(config.ifNot, {
                trigger: true,
                replace: true
              });
            }
          } else {
            return resolve();
          }
        });
      };

      SquareteamApp.prototype.routes = function() {
        var _this = this;
        this.router.route(['knowledge', 'knowledge/*path'], 'knowledge', function(path, ctx) {
          return console.log('knowledge');
        });
        this.router.route('login', 'login', function() {
          return require(['apps/public/login'], function(login) {
            return login(_this.ctx);
          });
        }, {
          acl: false
        });
        this.router.route('register', 'register', function() {
          return require(['apps/public/register'], function(register) {
            return register(_this.ctx);
          });
        }, {
          acl: false
        });
        this.router.route('home', 'home', function() {
          return require(['apps/home/default'], function(home) {
            return home(_this.ctx);
          });
        });
        return this.router.route('logout', 'logout', function() {
          var logout;
          logout = _this.ctx.get('app').session.logout();
          logout.then(function() {
            return _this.router.navigate('/login', {
              trigger: true,
              replace: true
            });
          });
          return logout["catch"](function() {
            this.router.setFlash('Unable to log you out');
            return this.router.navigate('/home', {
              trigger: true,
              replace: true
            });
          });
        });
      };

      return SquareteamApp;

    })();
    _.extend(SquareteamApp.prototype, Backbone.Events);
    return SquareteamApp;
  });

}).call(this);
