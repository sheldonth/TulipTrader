mongoose = require('mongoose')

userSchema = new mongoose.Schema {
    name:
        first:
            type: String,
            trim: true
        last:
            type: String,
            trim: true
    age:
        type: String
    email:
        type: String
    username:
        type: String
    password:
        type: String
}

#user is the model
user = mongoose.model 'User', userSchema

module.exports.userSchema = userSchema
module.exports.user = user