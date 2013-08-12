var express = require('express')
  , routes = require('./routes')
  , user = require('./routes/user')
  , http = require('http')
  , path = require('path')
  , ev = require('./routes/ev')
  , midtown = require('./routes/midtown')
  , wv = require('./routes/wv')
  , tribeca = require('./routes/tribeca')
  , meat = require('./routes/meat')
  , murray = require('./routes/murray')
  , faq = require('./routes/faq')
  , contact = require('./routes/contact')


app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 80);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('yoursecrethere'));
  app.use(express.session());
  app.use(app.router);
  app.use(require('stylus').middleware(__dirname + '/public'));
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/', routes.index);
app.get('/ev', ev.index);
app.get('/wv', wv.index);
app.get('/midtown', midtown.index);
app.get('/tribeca', tribeca.index);
app.get('/meat', meat.index);
app.get('/murray', murray.index);
app.get('/faq', faq.index);
app.get('/contact', contact.index);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});