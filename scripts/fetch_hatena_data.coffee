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
    # ブックマーク数、お気に入り数、お気に入られ数
    @oldSidebarURL = "http://b.hatena.ne.jp/#{@user.id}/sidebar?with_tags=0"
    # 最近のブックマークは、新旧で取れる情報とHTML構造がぜんぜん違うのでFeed使ったほうがよい
    @feedURL = "http://b.hatena.ne.jp/#{@user.id}/atomfeed"
  parseOldBookmarkInfo: ($) ->
    user = @user
    lis = $(".hatena-module-body ul li").map (idx, li) ->
      li = $(li)
      span_text = li.find("span").text()
      inner_text = li.text()
      bookmark_str = "ブックマーク数"
      favorite_str = "お気に入り"
      follower_str = "お気に入られ"
      switch span_text
        when bookmark_str
          t = inner_text.replace(bookmark_str, "")
          t = t.replace(/\s+/g, "")
          t = t.split(',').join('')
          user.profile.bookmark_count = t
        when favorite_str
          t = inner_text.replace(favorite_str, "")
          t = t.replace(/\s+/g, "")
          t = t.split(',').join('')
          user.profile.favorites_count = t
        when follower_str
          t = inner_text.replace(follower_str, "")
          t = t.replace(/\s+/g, "")
          t = t.split(',').join('')
          user.profile.favorited_count = t
    console.log user
  getBookmarkInfo: ->
    request @oldSidebarURL
      , (err, resp, body)=>
        if !err && resp.statusCode == 200
          $ = cheerio.load body
          @parseOldBookmarkInfo $
        else
          console.log "old bookmark failed", err
  updateUserData: ->
    @getBookmarkInfo()


for id in ["yuiseki", "tomad"]
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
