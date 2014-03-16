(function() {
  define(['when', 'backbone'], function(When) {
    return function(ctx) {
      return Backbone.Model.extend({
        url: "/user",
        secure: function(method) {
          if (method === "read" || method === "update" || method === "delete") {
            return true;
          } else {
            return false;
          }
        },
        schema: {
          name: 'Text',
          email: {
            validators: ['required', 'email']
          },
          password: {
            type: 'Password',
            validators: ['required']
          }
        },
        create: function(organization) {
          var defer,
            _this = this;
          if (organization == null) {
            organization = null;
          }
          defer = When.defer();
          this.save(null, {
            success: function() {
              var login_request;
              login_request = ctx.get('coreSession').login(_this.get('email'), _this.get('password'), true);
              login_request.then(function(session) {
                session.save();
                ctx.get('app').session = session;
                return defer.resolver.resolve();
              });
              return login_request["catch"](defer.resolver.reject);
            },
            error: function(e) {
              return defer.resolver.reject(e);
            }
          });
          return defer.promise;
        }
      });
    };
  });

}).call(this);
