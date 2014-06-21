config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

request = require "request"
cheerio = require "cheerio"
xml2js = require "xml2js"
async = require "async"


class HatenaClient
  constructor: (@user)->
    @bookmarkURL = "http://b.hatena.ne.jp/#{@user.id}/"
    @feedURL = "http://b.hatena.ne.jp/#{@user.id}/atomfeed"
    @user.profile.misc =
      new_page: null
      first_bookmark_offset: 0
      bookmarks_per_page: null
      feed_offset: 0

  parseUserBookmarkInfo: ($) ->
    console.log "parseUserBookmarkInfo"
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
  getUserBookmarkInfo: ->
    console.log "request", @bookmarkURL
    request @bookmarkURL
      , (err, resp, body)=>
        if !err && resp.statusCode == 200
          $ = cheerio.load body
          @parseUserBookmarkInfo $
          @getFirstBookmark()
        else
          console.log "bookmark failed", err
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
    console.log user.profile
    user.save(@finishCallback)
  getFirstBookmark: ()->
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
  createUserBookmarkModel: (entry, data, next) ->
    UserBookmark.findOrCreate {id:data.id}, (err, userBookmark) =>
      userBookmark.user = @user
      userBookmark.entry = entry
      userBookmark.comment = data.comment
      userBookmark.tags = data.tags
      userBookmark.timestamp = data.timestamp
      console.log userBookmark
      userBookmark.save(next)
  getRecentBookmarks: () ->
    if @user.profile.misc.feed_offset == 40
      @finishCallback()
      return
    feedUrl = @feedURL + "?of=#{@user.profile.misc.feed_offset}"
    console.log "request", feedUrl
    request feedUrl
      , (err, resp, body) =>
        xml2js.parseString body, (err, result) =>
          fetchNextBookmarks = =>
            @user.profile.misc.feed_offset += 20
            @getRecentBookmarks()
          saveOneEntry = (entry, done) =>
            data =
              id: entry.id[0]
              url: entry.link[0]["$"].href
              title: entry.title[0]
              tags: entry["dc:subject"]
              comment: entry.summary[0]
              timestamp: Date.parse(entry.issued[0])
            BookmarkEntry.findOrCreate {url:data.url, title:data.title}, (err, entry) =>
              @createUserBookmarkModel entry, data, done
          async.eachSeries result.feed.entry, saveOneEntry, fetchNextBookmarks
  parseBookmarkInfo: (url, $) ->
    count = $("ul.entry-page-unit li.entry-unit ul.users li strong a span").text()
    category = $(".entry-contents ul.entry-data li.category a").text()
    keywords = $("a.keyword")
  getBookmarkInfo: (url) ->
    # remove "http(s)?://"
    chopUrl = url.replace(/https?:\/\//, "")
    bookmarkInfoURL = "http://b.hatena.ne.jp/entry/"+url
    request bookmarkInfoURL, (err, resp, body) =>
      if !err && resp.statusCode == 200
        $ = cheerio.load body
        @parseBookmarkInfo url, $
    
  updateUserData: (done) ->
    @finishCallback = done
    #@getUserBookmarkInfo()
    @getRecentBookmarks()

user_ids = ["yuiseki"]
#user_ids = ["netcraft", "Lhankor_Mhy", "kamayan1980", "nisemono_san", "TERRAZI", "atq", "sabacurry", "nkoz", "hnnhn2", "kiku-chan", "Rlee1984", "yuiseki", "AnonymousLifeforms", "hyaknihyak", "dora-kou", "whkr", "kybernetes", "hinaho", "shields-pikes",  "pero_pero", "K_SHIKI", "yo-mei777", "rgfx", "new3", "kazoo_oo", "seagullwhite", "bulldra", "tomad"]
fetch = (id, done) ->
  console.log id
  user = User.findOrCreate {id:id}, (err, user) ->
    if !err
      client = new HatenaClient user
      client.updateUserData(done)
finishCallback = (err) ->
  mongoose.connection.close()
  process.exit()
async.eachSeries(user_ids, fetch, finishCallback)
