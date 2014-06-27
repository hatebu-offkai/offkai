config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

util = require "util"
async = require "async"
_ = require "underscore"

class UserAnalyzer
  constructor: (@user) ->
  run: (done) ->
    @finishCallback = done
    @analyzeUserBookmarks =>
      @analyzeUserSimilarity =>
        @finishCallback()
  analyzeUserBookmarks: (callback)->
    UserBookmark.find({user:@user},"entry").exec (err, result) =>
      if err?
        console.log err
        @finishCallback()
        return
      # entry._idだけの配列
      entries = _.map result, (r)->r.entry
      BookmarkEntry.find(_id:{$in:entries}).exec (err, bookmarks)=>
        if err?
          console.log err
          @finishCallback()
          return
        # bookmarksに対して実行したい処理全部
        async.applyEach [@countBookmarksCategory, @countBookmarksHatenaKeywords], bookmarks, ->
          callback()
  analyzeUserSimilarity: (callback)->
    User.find({_id:{$ne:@user._id}}).exec (err, users) =>
      if err?
        console.log err
        @finishCallback()
        return
      # usersに対して実行したい処理全部
      async.applyEach [@calculateKeywordSimilarity], users, ->
        callback()
  countBookmarksCategory: (bookmarks, callback)=>
    counter = {}
    iterateBookmark = (b, done)->
      if counter[b.category]?
        counter[b.category]++
      else
        counter[b.category]=1
      done()
    finishBookmark = (err) =>
      counted = _.map counter, (v,k)->[k,v]
      counted.sort (a, b)->b[1] - a[1]
      counted = _.map counted, (e)->{word:e[0], count:e[1]}
      @user.profile.categories = counted
      @user.save ->
        callback()
    async.eachSeries bookmarks, iterateBookmark, finishBookmark
  countBookmarksHatenaKeywords: (bookmarks, callback)=>
    counter = {}
    iterateBookmark = (b, done) ->
      if b.hatena_keywords?
        for keyword in b.hatena_keywords
          if counter[keyword]?
            counter[keyword]++
          else
            counter[keyword]=1
        done()
    finishBookmark = (err) =>
      counted = _.map counter, (v,k)->[k,v]
      counted.sort (a, b)->b[1] - a[1]
      counted = counted.slice(0, 19)
      counted = _.map counted, (e)->{word:e[0], count:e[1]}
      @user.profile.keywords = counted
      @user.save =>
        callback()
    async.eachSeries bookmarks, iterateBookmark, finishBookmark
  calculateKeywordSimilarity: (users, callback)=>
    cosineSimilarity = (a, b) ->
      dict = {}
      dict[elem.word] = true for elem in a
      dict[elem.word] = true for elem in b
      arrA = {}
      arrB = {}
      arrA[elem.word] = elem.count for elem in a
      arrB[elem.word] = elem.count for elem in b
      vecA = (arrA[term] ? 0 for term of dict)
      vecB = (arrB[term] ? 0 for term of dict)
      product = 0
      product += vecA[i] * vecB[i] for term, i in vecA
      magnitude = (vec) ->
        sum = 0
        sum += num * num for num in vec
        return Math.sqrt sum
      magA = magnitude vecA
      magB = magnitude vecB
      return product / (magA * magB)
    updateUserSimilarities = (user, opponent, similarity) ->
      similarities = user.profile.similarities ? {}
      similarities.keyword ?= []
      similarities.keyword = similarities.keyword.filter (v) ->
        return v.id != opponent.id
      similarities.keyword.push {id: opponent.id, value: similarity}
      user.profile.similarities = similarities
      return user
    iterateUser = (u, done) =>
      if u.profile.keywords?
        keywordSimilarity = cosineSimilarity @user.profile.keywords, u.profile.keywords
        console.log " #{u.id}:#{keywordSimilarity}"
        @user = updateUserSimilarities @user, u, keywordSimilarity
        u = updateUserSimilarities u, @user, keywordSimilarity
        @user.save (err) =>
          u.save done()
      else
        done()
    finishUser = (err) =>
      keyword = @user.profile.similarities.keyword
      sorting = _.map keyword, (e)-> [e.id, e.value]
      sorting.sort (a,b)->b[1] - a[1]
      sorted = _.map sorting, (e)->{id:e[0], value:e[1]}
      console.log sorted
      @user.profile.similarities.keyword = sorted
      @user.save =>
        callback()
    async.eachSeries users, iterateUser, finishUser
User.find({id:"yuiseki"}).exec (err, users)->
  iterate = (user, done)->
    console.log user.id
    client = new UserAnalyzer user
    client.run(done)
  finish = (err) ->
    console.log "finish"
    mongoose.connection.close()
    process.exit()
  if !err
    async.eachSeries users, iterate, finish
