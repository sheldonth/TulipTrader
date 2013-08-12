express = require 'express'

{loadSettings} = require './util'
settings = loadSettings()

app = express.createServer express.Logger()
app.set 'view engine', 'jade'
app.use express.bodyParser()
app.use app.router
app.use express.static "#{__dirname}/../public"
app.use express.errorHandler {dumpExceptions: true, showStack: true}

port = process.env.port or 3000
app.listen port, () ->
    console.log "Listening on #{port}"