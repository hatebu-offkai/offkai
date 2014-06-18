mongoose = require "mongoose"
Schema = mongoose.Schema
userSchema = new Schema
    id: String
    attend_comment: String
    attend_status: Bool
    profile:
        bookmark_count: Number
        favorites_count: Number
        favorited_count: Number
        first_bookmark:
            entry_title: String
            entry_link: String
            comment: String
            timestamp: Date
        titles: [String]
        keywords: [String]
        tags: [String]
    created: Date
    updated: Date
userSchema.pre "save", (next) ->
    if @isNew
        @created = new Date()
    @updated = new Date()
    next()

userSchema.set "toJSON",
    transform: (doc, ret, options)->
        return {
            id: ret.id
            icon: "http://cdn1.www.st-hatena.com/users/#{ret.id.slice(0,2)}/#{ret.id}/profile.gif"
            prifile: ret.profile
        }

exports.userSchema = userSchema
User = mongoose.model "User", userSchema
exports.User = User
