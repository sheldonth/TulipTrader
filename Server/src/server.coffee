express = require 'express'

{loadSettings} = require './util'
#settings = loadSettings()

app = express()
app.set 'port', 80
app.set 'views', __dirname + '/src/views/'
app.set 'view engine', 'jade'
app.locals.pretty = true
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session {secret: 'sheldon is the man'}
app.use app.router
app.use express.static "#{__dirname}/public"
app.use express.errorHandler {dumpExceptions: true, showStack: true}

router = require './router'

port = process.env.port or 3000
app.listen port, () ->
    console.log "Listening on #{port}"