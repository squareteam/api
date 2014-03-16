(function() {
  define(['core/session', 'core/models', 'core/router', 'core/api', 'core/api/sync'], function(Session, Models, Router, Api, ApiBackboneSync) {
    return {
      injectTo: function(ctx) {
        ApiBackboneSync(ctx);
        ctx.register('coreRouter').object(Router);
        ctx.register('coreSession').object(Session(ctx));
        ctx.register('coreApi').object(Api);
        return ctx.register('models').object(Models(ctx));
      }
    };
  });

}).call(this);
