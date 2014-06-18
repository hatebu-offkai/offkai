###
config = require "config"
mongoose = requrie "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
###

request = require "request"
cheerio = require "cheerio"

class HatenaClient
  constructor: (@user)->
    # ブックマークページ
    @bookmarkURL = "http://b.hatena.ne.jp/#{@user.id}/"
    # 最近のブックマークは、新旧で取れる情報とHTML構造がぜんぜん違うのでFeed使ったほうがよい
    @feedURL = "http://b.hatena.ne.jp/#{@user.id}/atomfeed"
  parseBookmarkInfo: ($) ->
    user = @user
    user.profile.misc = {}
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
    else
      first_bookmark_offset = 0
    user.profile.misc.first_bookmark_offset = first_bookmark_offset
    user.profile.misc.bookmarks_per_page = bookmarks_per_page
  getBookmarkInfo: ->
    request @bookmarkURL
      , (err, resp, body)=>
        if !err && resp.statusCode == 200
          $ = cheerio.load body
          @parseBookmarkInfo $
          @getFirstBookmark()
        else
          console.log "bookmark failed", err
  parseFirstBookmark: ($) ->
    user = @user
    user.profile.first_bookmark = {}
    entry_link = $('li[data-eid]:last-child h3 .entry-link')[0]
    if !entry_link
      if (user.profile.misc.first_bookmark_offset)
        user.profile.misc.first_bookmark_offset -= user.profile.misc.bookmarks_per_page
        @getFirstBookmark
      return
    user.profile.first_bookmark.entry_title = entry_link.children[0].data
    user.profile.first_bookmark.entry_link = entry_link.attribs.href
    user.profile.first_bookmark.timestamp = $("li[data-eid]:last-child li[data-user=\"#{user.id}\"] .timestamp")[0].children[0].data
    user.profile.first_bookmark.comment = $("li[data-eid]:last-child li[data-user=\"#{user.id}\"] .comment").text()
    console.log user
  getFirstBookmark: ()->
    request @bookmarkURL + "?of=#{@user.profile.misc.first_bookmark_offset}"
      , (err, resp, body)=>
        if !err && resp.statusCode == 200
          $ = cheerio.load body
          @parseFirstBookmark $
        else
          console.log "first bookmark failed", err
  updateUserData: ->
    @getBookmarkInfo()

# for id in ["yuiseki"]
for id in ["netcraft", "Lhankor_Mhy", "kamayan1980", "nisemono_san", "TERRAZI", "atq", "sabacurry", "nkoz", "hnnhn2", "kiku-chan", "Rlee1984", "yuiseki", "AnonymousLifeforms", "hyaknihyak", "dora-kou", "whkr", "kybernetes", "hinaho", "shields-pikes",  "pero_pero", "K_SHIKI", "yo-mei777", "rgfx", "new3", "kazoo_oo", "seagullwhite", "bulldra", "tomad"]
# for id in ["yuiseki", "tomad"]
  user =
    id: id
    profile: {}
  client = new HatenaClient user
  client.updateUserData()
###
User.find {}, (err, results) ->
  for user, idx, in results
    client = new HatenaClient user
    client.updateUserData()
    if idx == results.length
      mongoose.connection.close()
      process.exit()
###