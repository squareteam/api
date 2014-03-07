(function() {
  define(['core/session', 'core/models', 'core/router', 'core/api', 'core/api/sync'], function(Session, Models, Router, Api, ApiBackboneSync) {
    return {
      injectTo: function(container) {
        ApiBackboneSync(container);
        container.set('core.router', function(services) {
          return function(config) {
            return new Router(config, services);
          };
        });
        container.set('core.session', function() {
          return Session(container);
        });
        container.set('core.api', function() {
          return Api;
        });
        return container.set('models', function() {
          return Models;
        });
      }
    };
  });

}).call(this);
