// Generated by CoffeeScript 1.6.3
(function() {
  var accountmanager;

  accountmanager = require('./account-manager');

  module.exports = function(app) {
    return app.get('/', function(req, res) {
      return res.render('login', {
        title: 'Login'
      });
    });
  };

}).call(this);
