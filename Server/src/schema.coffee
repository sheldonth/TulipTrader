mongoose = require('mongoose')
{Schema} = mongoose
{ObjectId} = Schema
safeDate = require ('safe_datejs')

userSchema = new Schema {
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
        default: ""
    passhash:
        type: String
        default: ""
}

user = mongoose.model 'User', userSchema

contractSchema = new Schema {
    creationDate:
        type: Date
        default: safeDate.now()
        required: yes
    principle:
        type: Number
        required: yes
    paymentDate: 
        type: Date
        required: yes
        default: '1/1/1900'
    base58SendingAddress:
        type: String
        default: ""
        required: yes
        default:
    purchaser:
        type: ObjectId
        ref: 'User'
    expirationDate:
        type: Date
        required: yes
        default:"1/1/1900"
}

contract = mongoose.model 'Contract', contractSchema

module.exports.user = user
module.exports.contract = contract

