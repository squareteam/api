(function() {
  define(['backbone'], function() {
    return Backbone.Model.extend({
      url: "/organizations"
    });
  });

}).call(this);
