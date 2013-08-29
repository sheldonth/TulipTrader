accountmanager = require('./account-manager')

module.exports = (app) ->
    app.get '/', (req, res) ->
        if (!req.cookies.username? || !req.cookies.password?)
            console.log 'login'
            res.render 'login', {title: 'Login'}
        else
            console.log 'else'