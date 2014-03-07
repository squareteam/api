(function() {
  define(['core/models/user', 'core/models/organization'], function(User, Organization) {
    return {
      "User": User,
      "Organization": Organization
    };
  });

}).call(this);
