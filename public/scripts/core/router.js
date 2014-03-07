(function() {
  var __slice = [].slice;

  define(['when', 'when-sequence', 'loglevel', 'backbone'], function(When, When_sequence, log) {
    /*
       Yoda Router
    */

    var Router;
    return Router = Backbone.Router.extend({
      initialize: function(options, services) {
        this.services = services;
        this.default_configurators = options.default_configurators || {};
        this.default_route = options.default_route || null;
        this._configurators = [];
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
            var params, _configurators;
            params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            _configurators = [];
            configurators = _.extend(_.clone(_this.default_configurators), configurators);
            console.info("route " + name + " with configurators =", configurators);
            configurators = _.each(_.clone(configurators), function(configurator_config, configurator_name) {
              var configurator_scope;
              if (configurator_config !== false) {
                configurator_scope = function() {
                  var defer;
                  defer = When.defer();
                  _this._configurators[configurator_name].call(_this, _this.services, route, configurator_config, defer.resolver.resolve, defer.resolver.reject);
                  return defer.promise;
                };
                return _configurators.push(configurator_scope);
              }
            });
            return When_sequence(_configurators).done(function() {
              console.info('yeh');
              return callback(params, this.services);
            }, function(e) {
              return console.info('neh!', e);
            });
          });
        });
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
