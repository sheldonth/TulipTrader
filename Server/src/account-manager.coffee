crypto = require ('crypto')
{MongoClient, Server} = require ('mongodb')

dbPort =  27017;
dbHost = 'localhost';
dbName = 'node-login';

#Establish a client?

mongoClient = new MongoClient new Server 'localhost', 27017
mongoClient.open (err, mongoClient) ->
    db1 = mongoClient.db 'myDb'
    if (err)
        console.log("error opening #{e}")
    else
        console.log("connected to database :: " + db1)

#db = new MongoClient dbName, new Server(dbHost, dbPort, {auto_reconnect: true}), {w: 1}
#db.open (e, d) ->