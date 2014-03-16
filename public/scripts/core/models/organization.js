(function() {
  define(['backbone'], function() {
    return function(ctx) {
      return Backbone.Model.extend({
        url: "/organizations"
      });
    };
  });

}).call(this);
