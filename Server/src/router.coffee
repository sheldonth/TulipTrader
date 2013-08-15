account-manager = require('account-manager')

module.exports = (app) ->
    app.get '/', (req, res) ->
        res.render 'login', {title: 'Login'}
