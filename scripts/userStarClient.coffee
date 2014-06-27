config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"

request = require "request"
async = require "async"
_ = require "underscore"

class UserStarClient
  constructor: (@user)->
    @bookmarkURL = "http://b.hatena.ne.jp/#{@user.id}/"
    @starURL = "http://s.hatena.ne.jp/blog.json?uri="+@bookmarkURL
  run: (done) ->
    @finishCallback = done
    @getStarCountData()
  getStarCountData: ->
    console.log "request", @starURL
    request @starURL
      , (err, resp, body) =>
        if !err && resp.statusCode == 200
          json = JSON.parse body
          stared_count = parseInt(json.star_count, 10)
          @user.profile.stared_count = stared_count
          stared_count_detail = {blue:0, red:0, green:0, yellow:0}
          _.extend stared_count_detail, json.count
          @user.profile.stared_count_detail = stared_count_detail
          @user.save (err)=>
            console.log err
            console.log @user.profile.stared_count, @user.profile.stared_count_detail
            @finishCallback()
        else
          console.log "request failed", resq.statusCode, err
          @finishCallback()

User.find {}, (err, users)->
  iterate = (user, done)->
    console.log user.id
    client = new UserStarClient user
    client.run(done)
  finish = (err) ->
    console.log "finish"
    mongoose.connection.close()
    process.exit()
  if !err
    async.eachSeries(users, iterate, finish)
