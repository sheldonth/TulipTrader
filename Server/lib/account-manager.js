// Generated by CoffeeScript 1.6.3
(function() {
  var MongoClient, Server, crypto, db, dbHost, dbName, dbPort, _ref;

  crypto = require('crypto');

  _ref = require('mongodb'), MongoClient = _ref.MongoClient, Server = _ref.Server;

  dbPort = 27017;

  dbHost = 'localhost';

  dbName = 'node-login';

  db = new MongoClient(dbName, new Server(dbHost, dbPort, {
    auto_reconnect: true
  }), {
    w: 1
  });

  db.open(function(e, d) {
    if (e) {
      return console.log("error opening " + e);
    } else {
      return console.log("connected to database :: " + dbName);
    }
  });

}).call(this);
