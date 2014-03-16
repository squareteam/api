(function() {
  define(['hbs!apps/public/templates/login', 'core/models'], function(login_tpl, Models) {
    return function(ctx) {
      var form, submit, user,
        _this = this;
      submit = function(e) {
        var errors, login_request;
        if (e != null) {
          e.preventDefault();
        }
        errors = form.commit();
        if (_.size(errors) === 0) {
          login_request = ctx.get('coreSession').login(form.getValue('email'), form.getValue('password'), true);
          login_request.then(function(session) {
            session.save();
            ctx.get('app').session = session;
            return ctx.get('app').router.navigate('/home', {
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
      user = new (ctx.get('models').User)({
        email: "test@test.fr"
      });
      form = new Backbone.Form({
        model: user,
        fields: ['email', 'password']
      }).render();
      $(".squareteam-layout").html(login_tpl());
      $(".squareteam-layout .form").append(form.el);
      if (ctx.get('app').router.getFlash().length) {
        $(".squareteam-layout .alert").html(ctx.get('app').router.getFlash()[0]).show();
      }
      $('.squareteam-layout .btn-primary').on('click', submit);
      return form.on('submit', submit);
    };
  });

}).call(this);
