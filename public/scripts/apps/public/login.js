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
            return $(".squareteam-layout .alert").html(e.toString()).show();
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
      $('.squareteam-layout .btn-primary').on('click', submit);
      return form.on('submit', submit);
    };
  });

}).call(this);
