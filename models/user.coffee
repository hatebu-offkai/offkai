mongoose = require "mongoose"
findOrCreate = require "mongoose-findorcreate"
Schema = mongoose.Schema
userSchema = new Schema
    id: String
    attend_comment: String
    attend_status: Boolean
    bookmarks: [{type:Schema.Types.ObjectId, ref: 'Bookmark'}]
    profile:
        bookmark_count: Number
        favorites_count: Number
        favorited_count: Number
        stared_count: Number
        first_bookmark:
            entry_title: String
            entry_link: String
            comment: String
            timestamp: Date
        titles: [String]
        keywords: [String]
        tags: [String]
        good_users: [String]
    created: Date
    updated: Date
userSchema.plugin findOrCreate
userSchema.pre "save", (next) ->
    if @isNew
        @created = new Date()
    @updated = new Date()
    next()

userSchema.set "toJSON",
    transform: (doc, ret, options)->
        return {
            id: ret.id
            prifile: ret.profile
        }

exports.userSchema = userSchema
User = mongoose.model "User", userSchema
exports.User = User
