config = require "config"
mongoose = requrie "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"

fs = require "fs"
parse = require "csv-parse"

parser = parse {columns:true}, (err, data) ->
  for user in data
    user = new User()
    user.id = user["名前"]
    user.comment = user["コメント"]
    if user["参加ステータス"] == "参加"
      user.attend_status = true
    user.save()

fs.createReadStream(__dirname+"/atnd.csv").pipe(parser)
