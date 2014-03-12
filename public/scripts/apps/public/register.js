(function() {
  define(['hbs!apps/public/templates/register', 'core/models'], function(login_tpl, Models) {
    return function(services) {
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
        var login_request,
          _this = this;
        login_request = services.get('core.session').login(model.get('email'), model.get('password'), true);
        login_request.then(function(session) {
          session.save();
          services.set('session', session);
          return services.get('app').router.navigate('/home', {
            trigger: true,
            replace: true
          });
        });
        return login_request["catch"](function(e) {
          var message;
          message = "an strange error happened, try again in few minutes";
          return $(".squareteam-layout .alert").html(message).show();
        });
      };
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
          user.on('api_error', function() {
            return console.error(arguments);
          });
          return user.save(null, {
            success: handleSuccess,
            error: handleError
          });
        }
      });
    };
  });

}).call(this);
