config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

async = require "async"
_ = require "underscore"

MeCab = require "mecab-async"
mecab = new MeCab()

class BookmarkAnalyzer
  constructor: ()->
  run: (done)->
    @finishCallback = done
    @extractBookmarkEntries =>
      @finishCallback()
  extractBookmarkEntries: (callback)->
    # 名詞抽出してないやつを探してする
    BookmarkEntry.find({title_words:{$size:0}}).exec (err, bookmarks)=>
      if err?
        console.log err
        @finishCallback()
        return
      console.log bookmarks.length
      iterateBookmark = (b, done) ->
        mecab.parse b.title, (err, words)->
          nounWords = _.filter words, (wordData)->
            # 一文字は排除
            return false if wordData[0].length == 1
            # 名詞のみ抽出
            return true if wordData[1] == "名詞"
          nounWords = _.map nounWords, (nw)->nw[0]
          b.title_words = nounWords
          b.save ->
            done()
      finishBookmark = (err) =>
        callback()
      async.eachLimit bookmarks, 10, iterateBookmark, finishBookmark

finish = (err) ->
  console.log "finish"
  mongoose.connection.close()
  process.exit()
analyzer = new BookmarkAnalyzer()
analyzer.run(finish)
