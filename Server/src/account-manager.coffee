crypto = require ('crypto')
moment = require('moment')
{user} = require('./schema')
schema = require './schema'

exports.autoLogin = (username, password, callback) ->
    user.findOne {username: username}, (e, o) ->
        if o
            o.password == password ? callback o : callback null
        else
            callback null

exports.manualLogin = (username, password, callback) ->
    user.findOne {username : username}, (e, o) ->
        if (!o? or e)
            callback "User Error #{e}"
        else
            validatePassword password, o.password, (err, res) ->
                if res
                    callback null, o
                else
                    callback 'Invalid Password'

# callback here needs (err result)
exports.newAccount = (newData, callback) ->
    accounts.findOne username:newData.username, (err, object) ->
        if (object)
            callback 'username taken'
        else
            accounts.findOne name:newData.name, (err, object) ->
                if (object)
                    callback 'name taken'
                else
                    saltAndHash newData.password (hash) ->
                        newData.password = hash
                        newData.date = moment().format 'MMMM Do YYYY, hh:mm:ss a'
                        newUser = new user()

# crypto helpers

generateSalt = () ->
    set = '0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ'
    salt = ''
    for i in [0..10] by 1
        p = Math.floor Math.random() * set.length
        salt += set[p]
    salt

md5 = (str) ->
    crypto.createHash('md5').update(str).digest('hex')

saltAndHash = (password, callback) ->
    salt = generateSalt()
    callback(salt + md5(password + salt))

validatePassword = (plainPass, hashedPass, callback) ->
    salt = hashedPass.substr 0, 10
    validHash = salt + md5 plainPass + salt
    callback null, hashedPass == validHash

# getObjectId = (id) ->
#     return accounts.find