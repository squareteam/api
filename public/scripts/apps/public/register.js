(function() {
  define(['hbs!apps/public/templates/register'], function(login_tpl) {
    return function(ctx) {
      var form, handleError, handleSuccess, user,
        _this = this;
      handleError = function(model, error) {
        var message;
        message = "server are busy, try again in few minutes";
        if (new RegExp("Email has already been taken").test(error.toString())) {
          form.fields["email"].setError('Email has already been taken');
          return;
        }
        $(".squareteam-layout .alert").html(message).show();
      };
      handleSuccess = function(model) {
        return ctx.get('app').router.navigate('/home', {
          trigger: true,
          replace: true
        });
      };
      user = new (ctx.get('models').User)({
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
        var creation, errors;
        errors = form.commit();
        if (_.size(errors) === 0) {
          user.set(form.getValue());
          creation = user.create();
          creation.then(handleSuccess);
          return creation["catch"](handleError);
        }
      });
    };
  });

}).call(this);
