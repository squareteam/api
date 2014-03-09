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
        var data, request, secure, url;
        if (!(method === "create" || method === "read" || method === "update" || method === "delete")) {
          throw new Error("Api.sync: method not supported " + method);
        } else {

        }
        url = model.url;
        data = {};
        if ((options.data == null) && model && (method === 'create' || method === 'update' || method === 'patch')) {
          data = options.attrs || model.toJSON(options);
        }
        secure = model.secure != null ? model.secure(method) : true;
        request = services.get('api.extras')[methodMapper(method)](url, data, secure);
        request.then(options.success);
        return request["catch"](options.error);
      };
    };
  });

}).call(this);
