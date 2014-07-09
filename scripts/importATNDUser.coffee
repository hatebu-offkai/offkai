config = require "config"
mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"

async = require "async"
fs = require "fs"
parse = require "csv-parse"

updateOrCreateUser = (entry, done)->
  name = entry["名前"]
  id = entry["はてなID"]
  id = id.replace(/id:/, "")
  console.log name, id
  User.findOrCreate {id:id}, (err, user, created)->
    user.name = entry["名前"]
    user.attend_comment = entry["コメント"]
    if entry["参加ステータス"] == "参加"
      user.attend_status = true
    else
      user.attend_status = false
    if entry["二次会の参加を希望されますか？"] == "はい"
      user.attend_afterparty = true
    user.save ->
      done()

finish = (err)->
  mongoose.connection.close()
  process.exit()
parser = parse {columns:true}, (err, data) ->
  async.eachSeries data, updateOrCreateUser, finish

fs.createReadStream(__dirname+"/entry").pipe(parser)
