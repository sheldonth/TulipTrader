crypto = require ('crypto')
{MongoClient, Server} = require ('mongodb')

dbPort =  27017;
dbHost = 'localhost';
dbName = 'node-login';

#Establish a client?

db = new MongoClient dbName, new Server(dbHost, dbPort, {auto_reconnect: true}), {w: 1}
db.open (e, d) ->
    if (e)
        console.log("error opening #{e}")
    else
        console.log("connected to database :: " + dbName)