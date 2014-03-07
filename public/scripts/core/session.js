(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['app', 'when', "core/session/providers", 'core/models', 'cryptojs.pbkdf2', 'cryptojs.hmac.sha256'], function(app, When, SessionProviders, Models) {
    return function(services) {
      var Session, SessionAnonymous, supports_html5_storage;
      supports_html5_storage = function() {
        var e;
        try {
          return __indexOf.call(window, 'localStorage') >= 0 && window['localStorage'] !== null;
        } catch (_error) {
          e = _error;
          return false;
        }
      };
      Session = (function() {
        function Session(auth, user, provider) {
          this.auth = auth;
          this.user = user;
          this.provider = provider;
        }

        /*
           Status methods
        */


        Session.prototype.isAuthenticated = function() {
          return this.auth.isValid();
        };

        /*
           Public methods
        */


        Session.prototype.save = function() {
          if (this.provider != null) {
            return this.provider.store(this.auth);
          } else {
            throw new Error("No provider to save with..");
          }
        };

        Session.prototype.logout = function() {
          var defer;
          defer = When.defer();
          services.get('api.extras').update('logout', function(err, response) {
            this.provider.destroy();
            return defer.resolver[err != null ? err : {
              'reject': 'fullfil'
            }](err);
          });
          return defer.promise;
        };

        return Session;

      })();
      Session.getToken = function(login, password, salt1, salt2) {
        var hmac, pbkdf2;
        pbkdf2 = CryptoJS.PBKDF2(password, salt1, {
          keySize: 256 / 32,
          iterations: 1000,
          hasher: CryptoJS.algo.SHA256
        });
        hmac = CryptoJS.algo.HMAC.create(CryptoJS.algo.SHA256, salt2.concat(pbkdf2));
        hmac.update(login);
        return hmac.finalize();
      };
      Session.restore = function() {
        var auth, defer, found, provider, request;
        defer = When.defer();
        found = false;
        provider = null;
        _.each(SessionProviders, function(provider) {
          found = found || provider.empty();
          if (!provider.empty()) {
            provider = provider;
          }
        });
        if (!found) {
          defer.resolver.reject('session.anonymous');
        } else {
          auth = provider.retrieve();
          if (!auth) {
            defer.resolver.reject('session.anonymous');
          } else {
            request = new (services.get('core.api').Request)({
              url: "/user/me",
              method: "GET",
              auth: auth
            });
            services.get('core.api').Api.proceed(request).then((function(response) {
              return defer.resolver.resolve(new Session(auth, new Models.User(response.data), provider));
            })["catch"](function(error) {
              console.error("fails to validate session " + error);
              return defer.resolver.reject('session.invalid');
            }));
          }
        }
        return defer.promise;
      };
      Session.login = function(login, password, trusted_browser) {
        var defer, provider, tryLogin;
        if (trusted_browser == null) {
          trusted_browser = false;
        }
        defer = When.defer();
        provider = SessionProviders.Memory;
        if (trusted_browser && supports_html5_storage()) {
          provider = SessionProviders.LocalStorage;
        } else if (trusted_browser) {
          provider = SessionProviders.Cookies;
        }
        tryLogin = services.get('api.extras').update('/login', {
          identifier: login
        }, false);
        tryLogin.then(function(response) {
          var auth, check_session, request;
          if ((response.salt1 != null) && (response.salt2 != null)) {
            console.log("salts : " + response.salt1 + ", " + response.salt2);
            auth = new (services.get('core.api').Auth)(login, Session.getToken(login, password, CryptoJS.enc.Hex.parse(response.salt1), CryptoJS.enc.Hex.parse(response.salt2)));
            request = new (services.get('core.api').Request)({
              url: "/api/user/me",
              method: "GET",
              auth: auth
            });
            check_session = services.get('core.api').Api.proceed(request);
            check_session.then((function(response) {
              return defer.resolver.resolve(new Session(auth, new Models.User(response.data), new provider));
            }));
            return check_session["catch"](function(error) {
              console.error("fails to validate session " + error);
              return defer.resolver.reject('session.invalid');
            });
          } else {
            console.error("login.fail " + error);
            return defer.resolver.reject('login.fail');
          }
        });
        tryLogin["catch"](function(error) {
          console.error("login.fail " + error);
          return defer.resolver.reject('login.fail');
        });
        return defer.promise;
      };
      Session.Anonymous = SessionAnonymous = (function() {
        function SessionAnonymous() {}

        SessionAnonymous.prototype.isAuthenticated = function() {
          return false;
        };

        return SessionAnonymous;

      })();
      return Session;
    };
  });

}).call(this);
