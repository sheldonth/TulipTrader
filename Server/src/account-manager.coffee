crypto = require ('crypto')
moment = require('moment')
{MongoClient, Server} = require ('mongodb')
mongoose = require('mongoose')

dbUser = 'admin'
dbPass = 'alphaalphafoxtrot'
dbIP = '142.4.197.18'
dbPort = '27017'
dbString = "mongodb://#{dbUser}:#{dbPass}@#{dbIP}:#{dbPort}/"

schema = require './schema'

#poo
#Establish a client?

mongoose.connect dbString, (err, res) ->
    if err
        console.log 'MongoDb Connection Error'
    else
        console.log 'MongoDb Connection Successful'

#mongoClient = new MongoClient new Server 'localhost', 27017

# mongoClient.open (err, mongoClient) ->
#     if (err)
#         console.log("error opening #{e}")
#     else
#         console.log("connected to database :: " + mongoClient)#everything has to occur in this callback as it's currently set up
#         #porting to mongoose will fix this
# 
# db1 = mongoClient.db 'myDb'
# accounts = db1.collection 'accounts'

exports.autoLogin = (username, password, callback) ->
    console.log "user is #{user}"
    user.findOne {username: username}, (e, o) ->
        if o
            o.password == password ? callback o : callback null
        else
            callback null

exports.manualLogin = (username, password, callback) ->
    user.findOne {username:username}, (e, o) ->
        if (o == null)
            callback 'user-not-found'
        else
            validatePassword password, o.password, (err, res) ->
                if res
                    callback null, o
                else
                    callback 'invalid-password'

# callback here needs (err result)
exports.newAccount = (newData, callback) ->
    accounts.findOne {username:newData.username}, (err, object) ->
        if (object)
            callback 'username taken'
        else
            accounts.findOne {name:newData.name}, (err, object) ->
                if (object)
                    callback 'name taken'
                else
                    saltAndHash newData.password (hash) ->
                        newData.password = hash
                        newData.date = moment().format 'MMMM Do YYYY, h:mm:ss a'
                        console.log "Inserting New User: #{newData}"
                        # accounts.insert newData, {w: 1}, callback

# console.log 'collectionnames are ' + accounts.collectionNames

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

# findByMultipleFields