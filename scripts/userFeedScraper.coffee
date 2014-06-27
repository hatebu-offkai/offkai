config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"

{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

request = require "request"
xml2js = require "xml2js"
async = require "async"

class UserFeedScraper
  constructor: (@user)->
    @feedURL = "http://b.hatena.ne.jp/#{@user.id}/atomfeed"
    @offsetUnit = 20
    @maxOffset = 500
    @user.profile.misc =
      feed_offset: 0
  run: (done) ->
    @finishCallback = done
    @getRecentBookmarks()
  getRecentBookmarks: () ->
    if @user.profile.misc.feed_offset == @maxOffset
      @finishCallback()
      return
    feedUrl = @feedURL + "?of=#{@user.profile.misc.feed_offset}"
    console.log "request", feedUrl
    request feedUrl
      , (err, resp, body) =>
        xml2js.parseString body, (err, result) =>
          fetchNextBookmarks = =>
            @user.profile.misc.feed_offset += @offsetUnit
            @getRecentBookmarks()
          saveOneEntry = (entry, done) =>
            data =
              id: entry.id[0]
              url: entry.link[0]["$"].href
              title: entry.title[0]
              tags: entry["dc:subject"]
              comment: entry.summary[0]
              timestamp: Date.parse(entry.issued[0])
            BookmarkEntry.findOrCreate {url:data.url, title:data.title}, (err, entry, created) =>
              @saveUserBookmarkModel entry, data, done
              if !created
                @finishCallback()
          if result.feed.entry?
            async.eachSeries result.feed.entry, saveOneEntry, fetchNextBookmarks
          else
            @finishCallback()
  saveUserBookmarkModel: (entry, data, next) ->
    UserBookmark.findOrCreate {id:data.id}, (err, userBookmark) =>
      userBookmark.user = @user
      userBookmark.entry = entry
      userBookmark.comment = data.comment
      userBookmark.tags = data.tags
      userBookmark.timestamp = data.timestamp
      userBookmark.save(next)

User.find {}, (err, users)->
  iterate = (user, done) ->
    scraper = new UserFeedScraper user
    scraper.run(done)
  finish = (err) ->
    console.log "finish"
    mongoose.connection.close()
    process.exit()
  if !err
    async.eachSeries(users, iterate, finish)



