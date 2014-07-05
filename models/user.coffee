mongoose = require "mongoose"
findOrCreate = require "mongoose-findorcreate"
helper = require "./modelHelper"
Schema = mongoose.Schema
userSchema = new Schema
  id: String
  attend_comment: String
  attend_status: Boolean
  bookmarks: [{type:Schema.Types.ObjectId, ref: 'UserBookmark'}]
  profile:
    bookmark_count: Number
    favorites_count: Number
    favorited_count: Number
    stared_count: Number
    stared_count_detail: Schema.Types.Mixed
    first_bookmark:
      entry_title: String
      entry_link: String
      comment: String
      timestamp: Date
    categories: [Schema.Types.Mixed]
    keywords: [Schema.Types.Mixed]
    titles: [Schema.Types.Mixed]
    tags: [Schema.Types.Mixed]
    similarities:
      keyword: [Schema.Types.Mixed]
      title: [Schema.Types.Mixed]
      tag: [Schema.Types.Mixed]
  created: Date
  updated: Date
userSchema.plugin findOrCreate
userSchema.pre "save", helper.updateDate
userSchema.set "toJSON",
  transform: (doc, user, options)->
    return {
      id: user.id
      icon_n: "http://cdn1.www.st-hatena.com/users/"+user.id.slice(0,2)+"/"+user.id+"/profile.gif"
      icon_s: "http://cdn1.www.st-hatena.com/users/"+user.id.slice(0,2)+"/"+user.id+"/profile_s.gif"
      profile: user.profile
    }
exports.userSchema = userSchema
User = mongoose.model "User", userSchema
exports.User = User
