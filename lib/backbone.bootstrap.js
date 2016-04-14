(function() {
  'use strict';

  var globals = typeof window === 'undefined' ? global : window;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = ({}).hasOwnProperty;

  var endsWith = function(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  };

  var _cmp = 'components/';
  var unalias = function(alias, loaderPath) {
    var start = 0;
    if (loaderPath) {
      if (loaderPath.indexOf(_cmp) === 0) {
        start = _cmp.length;
      }
      if (loaderPath.indexOf('/', start) > 0) {
        loaderPath = loaderPath.substring(start, loaderPath.indexOf('/', start));
      }
    }
    var result = aliases[alias + '/index.js'] || aliases[loaderPath + '/deps/' + alias + '/index.js'];
    if (result) {
      return _cmp + result.substring(0, result.length - '.js'.length);
    }
    return alias;
  };

  var _reg = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (_reg.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';
    path = unalias(name, loaderPath);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has.call(cache, dirIndex)) return cache[dirIndex].exports;
    if (has.call(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  require.register = require.define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  require.list = function() {
    var result = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  require.brunch = true;
  require._cache = cache;
  globals.require = require;
})();
require.register("backbone.bootstrap/application", function(exports, require, module) {
var Application,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = Application = (function() {
  function Application(options) {
    if (options == null) {
      options = {};
    }
    this._cacheSync = __bind(this._cacheSync, this);
    this._cacheElement = __bind(this._cacheElement, this);
    this.cache = new (require('./cache'));
    return this;
  }

  Application.prototype.initialize = function(options) {
    if (options == null) {
      options = {};
    }
    this._cacheBootstrapData();
    if (this.cache.count() > 0) {
      this._overrideBackboneSync();
    }
    return this;
  };

  Application.prototype._cacheBootstrapData = function() {
    return $('script[type="application/json"][data-url]').each(this._cacheElement);
  };

  Application.prototype._cacheElement = function(index, element) {
    var bootstrap, data, e, _ref;
    bootstrap = $(element);
    try {
      data = JSON.parse(bootstrap.html());
      return this.cache.set(bootstrap.data('url'), {
        value: data,
        usage: (_ref = bootstrap.data('usage')) != null ? _ref : 'once'
      });
    } catch (_error) {
      e = _error;
      return typeof console !== "undefined" && console !== null ? console.warn('backbone.bootstrap - Invalid JSON for ' + bootstrap.data('url') + ' was not cached.') : void 0;
    }
  };

  Application.prototype._cacheSync = function(options) {
    var cacheKey, data, method, _ref;
    if (options == null) {
      options = {};
    }
    cacheKey = options.url;
    if (options.data != null) {
      if (cacheKey.indexOf('?') < 0) {
        cacheKey += "?";
      } else {
        cacheKey += "&";
      }
      cacheKey += _.isString(options.data) ? options.data : jQuery.param(options.data);
    }
    method = (_ref = options.type) != null ? _ref.toLowerCase() : void 0;
    if (method === "get") {
      if ((data = this.cache.get(cacheKey)) !== null) {
        options.success(data.value);
        if (data.usage === 'once') {
          this.cache.remove(cacheKey);
        }
        return true;
      }
    } else if (method === "delete" || method === "put") {
      this.cache.remove(cacheKey);
    }
    return this.BackboneSync.apply(this, [options]);
  };

  Application.prototype._overrideBackboneSync = function() {
    this.BackboneSync = Backbone.ajax;
    return Backbone.ajax = this._cacheSync;
  };

  return Application;

})();

});

require.register("backbone.bootstrap/cache", function(exports, require, module) {
var Cache;

module.exports = Cache = (function() {
  function Cache(options) {
    if (options == null) {
      options = {};
    }
    this._cache = {};
    return this;
  }

  Cache.prototype.get = function(key) {
    if (_.has(this._cache, key)) {
      return this._cache[key];
    }
    return null;
  };

  Cache.prototype.set = function(key, object) {
    this._cache[key] = object;
    return _.has(this._cache, key);
  };

  Cache.prototype.remove = function(key) {
    delete this._cache[key];
    return !_.has(this._cache, key);
  };

  Cache.prototype.listKeys = function() {
    return _.keys(this._cache);
  };

  Cache.prototype.count = function() {
    return _.size(this._cache);
  };

  return Cache;

})();

});

(function() {
  $(document).ready(function() {
    return (new (require('backbone.bootstrap/application'))).initialize();
  });

}).call(this);

