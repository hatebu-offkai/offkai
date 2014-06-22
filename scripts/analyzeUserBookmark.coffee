config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

async = require "async"
_ = require "underscore"

class UserAnalyzer
  constructor: (@user) ->
  run: (done) ->
    @finishCallback = done
    #@countEntriesCategory()
    @countHatenaKeywords()
  getUserBookmarkEntries: (callback)->
    UserBookmark.find({user:@user},"entry").exec (err, result) =>
      if err?
        console.log err
        @finishCallback()
        return
      # entry._idだけの配列
      entries = _.map result, (r)->r.entry
      BookmarkEntry.find(_id:{$in:entries}).exec (err, bookmarks)=>
        if err?
          console.log err
          @finishCallback()
          return
        callback bookmarks
  countEntriesCategory: ->
    @getUserBookmarkEntries (bookmarks)=>
      counter = {}
      iterateBookmark = (b, done)->
        if counter[b.category]?
          counter[b.category]++
        else
          counter[b.category]=1
        done()
      finishBookmark = (err) =>
        counted = _.map counter, (v,k)->[k,v]
        counted.sort (a, b)->b[1] - a[1]
        @user.profile.main_category = counted[0][0]
        @user.profile.sub_category = counted[1][0]
        console.log @user
        @user.save @finishCallback
      async.eachSeries bookmarks, iterateBookmark, finishBookmark
  countHatenaKeywords: ->
    @getUserBookmarkEntries (bookmarks)=>
      counter = {}
      iterateBookmark = (b, done) ->
        if b.hatena_keywords?
          for keyword in b.hatena_keywords
            if counter[keyword]?
              counter[keyword]++
            else
              counter[keyword]=1
          done()
      finishBookmark = (err) =>
        counted = _.map counter, (v,k)->[k,v]
        counted.sort (a, b)->b[1] - a[1]
        console.log counted.slice(0, 19)
        @finishCallback()
      async.eachSeries bookmarks, iterateBookmark, finishBookmark

User.find({id:"yuiseki"}).exec (err, users)->
  iterate = (user, done)->
    client = new UserAnalyzer user
    client.run(done)
  finish = (err) ->
    console.log "finish"
    mongoose.connection.close()
    process.exit()
  if !err
    async.eachSeries users, iterate, finish
