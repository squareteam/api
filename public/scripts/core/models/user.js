(function() {
  define(['backbone'], function() {
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
      }
    });
  });

}).call(this);
