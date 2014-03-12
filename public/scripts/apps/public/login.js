(function() {
  define(['hbs!apps/public/templates/login', 'core/models'], function(login_tpl, Models) {
    return function(services) {
      var form, submit, user,
        _this = this;
      submit = function(e) {
        var errors, login_request;
        if (e != null) {
          e.preventDefault();
        }
        errors = form.commit();
        if (_.size(errors) === 0) {
          login_request = services.get('core.session').login(form.getValue('email'), form.getValue('password'), true);
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
            message = "server are busy, try again in few minutes";
            if (e.toString() === "session.invalid") {
              message = "Wrong password";
            } else if (e.toString() === "login.fail") {
              message = "Wrong email";
            }
            return $(".squareteam-layout .alert").html(message).show();
          });
        }
      };
      user = new Models.User({
        email: "test@test.fr"
      });
      form = new Backbone.Form({
        model: user,
        fields: ['email', 'password']
      }).render();
      $(".squareteam-layout").html(login_tpl());
      $(".squareteam-layout .form").append(form.el);
      if (services.get('app').router.getFlash().length) {
        $(".squareteam-layout .alert").html(services.get('app').router.getFlash().join('<br>')).show();
      }
      $('.squareteam-layout .btn-primary').on('click', submit);
      return form.on('submit', submit);
    };
  });

}).call(this);
