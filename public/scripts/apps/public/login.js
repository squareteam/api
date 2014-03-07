(function() {
  define(['hbs!apps/public/templates/login', 'core/models'], function(login_tpl, Models) {
    return function(services) {
      var form, user,
        _this = this;
      user = new Models.User({});
      form = new Backbone.Form({
        model: user,
        fields: ['email', 'password']
      }).render();
      form.on('submit', function(e) {
        return e.preventDefault();
      });
      $(".squareteam-layout").html(login_tpl());
      $(".squareteam-layout .form").append(form.el);
      return $('.squareteam-layout .btn-primary').on('click', function() {
        var errors, login_request;
        errors = form.commit();
        if (_.size(errors) === 0) {
          login_request = services.get('core.session').login(form.getValue('email'), form.getValue('password'), true);
          login_request.then(function(session) {
            this.container.set('session', session);
            return this.container.get('app').router.navigate('/home');
          });
          return login_request["catch"](function(e) {
            return $(".squareteam-layout .alert").html(e.toString()).show();
          });
        }
      });
    };
  });

}).call(this);
