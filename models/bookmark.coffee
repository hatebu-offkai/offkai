mongoose = require "mongoose"
findOrCreate = require "mongoose-findorcreate"
helper = require "./modelHelper"
Schema = mongoose.Schema

bookmarkEntrySchema = new Schema
  url: String
  title: String
  bookmark_count: Number
  category: String
  title_words: [String]
  hatena_keywords: [String]
  timestamp: Date
  created: Date
  updated: Date
bookmarkEntrySchema.plugin findOrCreate
bookmarkEntrySchema.pre "save", helper.updateDate
exports.bookmarkEntrySchema = bookmarkEntrySchema
BookmarkEntry = mongoose.model "BookmarkEntry", bookmarkEntrySchema
exports.BookmarkEntry = BookmarkEntry

userBookmarkSchema = new Schema
  id: String
  user: {type:Schema.Types.ObjectId, ref:'User'}
  entry: {type:Schema.Types.ObjectId, ref:'BookmarkEntry'}
  comment: String
  tags: [String]
  timestamp: Date
  created: Date
  updated: Date
userBookmarkSchema.plugin findOrCreate
userBookmarkSchema.pre "save", helper.updateDate
exports.userBookmarkSchema = userBookmarkSchema
UserBookmark = mongoose.model "UserBookmark", userBookmarkSchema
exports.UserBookmark = UserBookmark
