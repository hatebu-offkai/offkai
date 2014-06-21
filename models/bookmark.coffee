mongoose = require "mongoose"
findOrCreate = require "mongoose-findorcreate"
Schema = mongoose.Schema
bookmarkSchema = new Schema
  user: {type:Schema.Types.ObjectId, ref:'User'}
  url: String
  comment: String
  title: String
  title_words: [String]
  hatena_keywords: [String]
  tags: [String]
  star_count: Number
  timestamp: Date
  created: Date
  updated: Date
bookmarkSchema.plugin findOrCreate
bookmarkSchema.pre "save", (next) ->
    if @isNew
        @created = new Date()
    @updated = new Date()
    next()

exports.bookmarkSchema = bookmarkSchema
Bookmark = mongoose.model "Bookmark", bookmarkSchema
exports.Bookmark = Bookmark
