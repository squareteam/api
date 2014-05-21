(function() {
  var __slice = [].slice;

  define(['when', 'when-sequence', 'loglevel', 'backbone'], function(When, When_sequence, log) {
    /*
       Yoda Router
    */

    var Router;
    return Router = Backbone.Router.extend({
      initialize: function(options) {
        var _this = this;
        console.log('Router', options);
        this.dependencies = 'session';
        this.flashes = [];
        this.flash_ttl = 2;
        this.default_configurators = options.default_configurators || {};
        this.default_route = options.default_route || null;
        this._configurators = [];
        this.on('route', function() {
          if (_this.flash_ttl === 0) {
            _this.flashes = [];
            return _this.flash_ttl = 2;
          } else {
            return _this.flash_ttl--;
          }
        });
      },
      setApp: function(app) {
        return this.app = app;
      },
      configurator: function(name, handler) {
        if (this._configurators[name] != null) {
          throw new Error("Duplicate name for configurator " + name);
        }
        return this._configurators[name] = handler;
      },
      route: function(routes, name, callback, configurators) {
        var _this = this;
        if (configurators == null) {
          configurators = {};
        }
        if (!_(routes).isArray()) {
          routes = [routes];
        }
        return _.each(routes, function(route) {
          return Backbone.Router.prototype.route.call(_this, route, name, function() {
            var configurators_with_defaults, params, _configurators;
            params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            _configurators = [];
            configurators_with_defaults = _.extend(_.clone(_this.default_configurators), configurators);
            console.info("route " + name + " with configurators =", configurators_with_defaults);
            _.each(configurators_with_defaults, function(configurator_config, configurator_name) {
              var configurator_scope;
              if (configurator_config !== false) {
                configurator_scope = function() {
                  var defer;
                  defer = When.defer();
                  _this._configurators[configurator_name].call(_this, _this.app, route, configurator_config, defer.resolver.resolve, defer.resolver.reject);
                  return defer.promise;
                };
                return _configurators.push(configurator_scope);
              }
            });
            return When_sequence(_configurators).done(function() {
              return callback(params, this.services);
            }, function(e) {
              return console.info('route rejected by configurator', e);
            });
          });
        });
      },
      setFlash: function(message) {
        return this.flashes.push(message);
      },
      getFlash: function() {
        return this.flashes;
      },
      boot: function() {
        console.info('Router.boot !');
        Backbone.history.start();
        if (Backbone.history.fragment.length === 0 && this.default_route !== null) {
          log.info("boot on " + this.default_route);
          return this.navigate(this.default_route, {
            trigger: true,
            replace: true
          });
        }
      }
    });
  });

}).call(this);