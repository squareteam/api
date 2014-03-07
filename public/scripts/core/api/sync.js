(function() {
  define(["backbone", "core/api"], function(Api) {
    return function(services) {
      var methodMapper;
      methodMapper = function(method) {
        var helpers;
        helpers = {
          "read": "read",
          "create": "create",
          "update": "update",
          "delete": "destroy"
        };
        return helpers[method];
      };
      return Backbone.sync = function(method, model, options) {
        var data, secure, url;
        if (!(method === "create" || method === "read" || method === "update" || method === "delete")) {
          throw new Error("Api.sync: method not supported " + method);
        } else {

        }
        url = model.url;
        data = {};
        if (model.secure != null) {
          secure = model.secure(method);
        } else {
          secure = true;
        }
        return services.get('api.extras')[methodMapper(method)](url, data, secure).then(options.success)["catch"](options.error);
      };
    };
  });

}).call(this);
