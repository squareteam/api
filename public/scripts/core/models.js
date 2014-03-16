(function() {
  define(['core/models/user', 'core/models/organization'], function(User, Organization) {
    return function(ctx) {
      return {
        "User": User(ctx),
        "Organization": Organization(ctx)
      };
    };
  });

}).call(this);
