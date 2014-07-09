config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

request = require "request"
cheerio = require "cheerio"
async = require "async"

class UserPageScraper
  constructor: (@user)->
    @bookmarkURL = "http://b.hatena.ne.jp/#{@user.id}/"
    @user.profile.misc =
      new_page: null
      first_bookmark_offset: 0
      bookmarks_per_page: null
  run: (done) ->
    @finishCallback = done
    if @user.id == ""
      console.log "Please input valid user id", @user.name
      @finishCallback()
    else
      @getUserBookmarkInfo()
  getUserBookmarkInfo: ->
    console.log "request", @bookmarkURL
    request @bookmarkURL
      , (err, resp, body)=>
        if !err && resp.statusCode == 200
          $ = cheerio.load body
          @parseUserBookmarkInfo $
        else
          console.log "request failed", @user.id, resp.statusCode, err
          @finishCallback()
  parseUserBookmarkInfo: ($) ->
    console.log "parseUserBookmarkInfo", @user.id
    user = @user
    user.profile.misc.new_page = $("#hatena-bookmark-user-page").length
    if user.profile.misc.new_page
      li_selector = "#profile-count-navi dl"
      span_selector = "dt"
    else
      li_selector = ".hatena-module.hatena-module-profile>.hatena-module-body li"
      span_selector = "span"
    lis = $(li_selector).map (idx, li) ->
      li = $(li)
      span_text = li.find(span_selector).text()
      inner_text = li.text()
      bookmark_str = "ブックマーク"
      favorite_str = "お気に入り"
      follower_str = "お気に入られ"
      if span_text.indexOf(bookmark_str) >= 0
        t = inner_text.replace(/\D/g, "")
        t = t.replace(/\s+/g, "")
        t = t.split(',').join('')
        user.profile.bookmark_count = t
      else if span_text.indexOf(favorite_str) >= 0
        t = inner_text.replace(favorite_str, "")
        t = t.replace(/\s+/g, "")
        t = t.split(',').join('')
        user.profile.favorites_count = t
      else if span_text.indexOf(follower_str) >= 0
        t = inner_text.replace(follower_str, "")
        t = t.replace(/\s+/g, "")
        t = t.split(',').join('')
        user.profile.favorited_count = t
    pager_next = $('.pager-next')[0]
    if !pager_next then bookmarks_per_page = 0 else bookmarks_per_page = $('.pager-next')[0].children[0].data.replace(/\D/g, '')
    if bookmarks_per_page
      first_bookmark_offset = (Math.floor(Number(user.profile.bookmark_count) / bookmarks_per_page) * bookmarks_per_page)
      user.profile.misc.first_bookmark_offset = first_bookmark_offset
    user.profile.misc.bookmarks_per_page = bookmarks_per_page
    user.save =>
      @getFirstBookmark()
  getFirstBookmark: ()->
    if @user.profile.first_bookmark.title?
      console.log "first_bookmark already exists, finish", @user.id
      console.log @user.profile.first_bookmark.title
      @finishCallback()
    else
      firstBookmarkUrl = @bookmarkURL + "?of=#{@user.profile.misc.first_bookmark_offset}"
      console.log "request", firstBookmarkUrl
      request firstBookmarkUrl
        , (err, resp, body)=>
          if !err && resp.statusCode == 200
            $ = cheerio.load body
            @parseFirstBookmark $
          else
            console.log "first bookmark failed", err
            console.log resp.statusCode
            @finishCallback()
  parseFirstBookmark: ($) ->
    console.log "parseFirstBookmark"
    user = @user
    user.profile.first_bookmark = {}
    entry_link = $('li[data-eid]:last-child h3 .entry-link')[0]
    if !entry_link
      if (user.profile.misc.first_bookmark_offset)
        user.profile.misc.first_bookmark_offset -= user.profile.misc.bookmarks_per_page
        @getFirstBookmark()
      return
    user.profile.first_bookmark.entry_title = entry_link.children[0].data
    user.profile.first_bookmark.entry_link = entry_link.attribs.href
    user.profile.first_bookmark.comment = $("li[data-eid]:last-child li[data-user=\"#{user.id}\"] .comment").text()
    user.profile.first_bookmark.timestamp = Date.parse $("li[data-eid]:last-child li[data-user=\"#{user.id}\"] .timestamp")[0].children[0].data
    console.log "finish", @user.id
    user.save =>
      @finishCallback()

User.find {attend_status:true}, (err, users)->
  iterate = (user, done) ->
    console.log "----"
    console.log user.id
    client = new UserPageScraper user
    client.run(done)
  finish = (err) ->
    mongoose.connection.close()
    process.exit()
  if !err
    async.eachSeries(users, iterate, finish)
