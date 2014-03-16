(function() {
  define(['hbs!apps/home/templates/home', 'core/models'], function(home_tpl, Models) {
    return function(ctx) {
      var organizations, region;
      region = $(".squareteam-layout");
      region.html(home_tpl({
        user: ctx.get('app').session.user.attributes
      }));
      organizations = new (ctx.get('models').Organization)();
      return organizations.fetch({
        success: function(m, resp) {
          var list;
          if (resp.length) {
            list = "";
            _.each(resp, function(organization) {
              return list += "<li>" + organization.name + "</li>";
            });
            return region.find('.organizations').html("<ul>" + list + "</ul>");
          } else {
            return region.find('.organizations').html('No results');
          }
        },
        error: function() {
          return console.error(arguments);
        }
      });
    };
  });

}).call(this);
