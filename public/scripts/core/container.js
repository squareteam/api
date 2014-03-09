(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define([], function() {
    var Container, ContainerError;
    ContainerError = (function(_super) {
      __extends(ContainerError, _super);

      function ContainerError() {}

      return ContainerError;

    })(Error);
    return Container = (function() {
      function Container(debug) {
        this.debug = debug != null ? debug : false;
        this.services = {};
        if (this.debug) {
          window.Container = this;
        }
      }

      Container.prototype.set = function(name, closure) {
        return this.services[name] = closure;
      };

      Container.prototype.setSingleton = function(name, closure) {
        this.set(name, closure);
        return this.services[name].singleton = true;
      };

      Container.prototype.get = function(name) {
        if (this.services[name] != null) {
          if (this.services[name].singleton) {
            if (typeof this.services[name] === 'function') {
              this.services[name] = this.services[name](this);
            }
            return this.services[name];
          } else {
            if (typeof this.services[name] === "function") {
              return this.services[name](this);
            } else {
              return this.services[name];
            }
          }
        } else {
          throw new ContainerError("Unknown service " + name + "'");
        }
      };

      Container.prototype.bound = function(closure) {
        return closure(this);
      };

      return Container;

    })();
  });

}).call(this);
