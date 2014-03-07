(function() {
  define(['hbs!apps/public/templates/register', 'core/models'], function(login_tpl, Models) {
    return function(services) {
      var form, user,
        _this = this;
      user = new Models.User({
        name: "test",
        email: "test@test.fr"
      });
      form = new Backbone.Form({
        model: user
      }).render();
      form.on('submit', function(e) {
        return e.preventDefault();
      });
      $(".squareteam-layout").html(login_tpl());
      $(".squareteam-layout .form").append(form.el);
      return $('.squareteam-layout .btn-primary').on('click', function() {
        var errors;
        errors = form.commit();
        if (_.size(errors) === 0) {
          user.set(form.getValue());
          return user.save({});
        }
      });
    };
  });

}).call(this);
