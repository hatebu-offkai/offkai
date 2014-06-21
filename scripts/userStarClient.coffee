config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"

request = require "request"
async = require "async"

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
          @user.profile.stared_count = json.star_count
          @user.save(@finishCallback)
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
    async.eachSeries users, iterate, finish
