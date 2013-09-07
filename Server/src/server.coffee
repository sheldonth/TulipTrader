express = require 'express'
{loadSettings} = require './util'
{MongoClient, Server} = require ('mongodb')
mongoose = require('mongoose')
router = require ('./router')

REDIS_PORT = 6379
REDIS_HOST = '127.0.0.1'
DB_HOST = '127.0.0.1'
dbUser = 'admin'
dbPass = 'alphaalphafoxtrot'
dbIP = '142.4.197.18'
dbPort = '27017'
dbString = "mongodb://#{dbUser}:#{dbPass}@#{dbIP}:#{dbPort}/"

mongoose.connect dbString, (err, res) ->
    if err
        console.log "MongoDb Connection #{err}"
    else
        console.log 'MongoDb Connection Successful'
        app = express()
        app.set 'port', 80
        app.set 'views', './src/views/'
        app.set 'view engine', 'jade'
        app.locals.pretty = true
        app.use express.bodyParser()
        app.use express.cookieParser()
        app.use express.session {secret: 'sheldon is the man'}
        app.use app.router
        app.use express.static "./public"
        app.use express.errorHandler {dumpExceptions: true, showStack: true}
        router = require './router'
        router app
        port = process.env.port or 3000
        app.listen port, () ->
            console.log "Listening on #{port}"