accountmanager = require('./account-manager')

module.exports = (app) ->
    app.get '/', (req, res) ->
        if (!req.cookies.username? || !req.cookies.password?)
            res.render 'login', title : 'Login'
            
    app.get '/signup', (req, res) ->
        res.render 'signup',
            title : "Sign Up"