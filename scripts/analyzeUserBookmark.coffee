config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "../models/user"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry
UserBookmark = bookmarkModel.UserBookmark

async = require "async"
_ = require "underscore"

class UserAnalyzer
  constructor: (@user) ->
  run: (done) ->
    @finishCallback = done
    @countEntriesCategory()
  getUserBookmarkEntries: (callback)->
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
        callback bookmarks
  getUsers: (callback) ->
    User.find({_id:{$ne:@user._id}}).exec (err, users) =>
      if err?
        console.log err
        @finishCallback()
        return
      callback users
  countEntriesCategory: ->
    @getUserBookmarkEntries (bookmarks)=>
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
        @user.save =>
          @countHatenaKeywords()
      async.eachSeries bookmarks, iterateBookmark, finishBookmark
  countHatenaKeywords: ->
    @getUserBookmarkEntries (bookmarks)=>
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
          @calculateKeywordSimilarity()
      async.eachSeries bookmarks, iterateBookmark, finishBookmark
  calculateKeywordSimilarity: ->
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
    goodUser = (similarities) ->
      biggest = {value: 0}
      for s in similarities
        biggest = s if s.value > biggest.value
      return biggest.id
    updateUserSimilarities = (user, opponent, similarity) ->
      similarities = user.profile.similarities ? {}
      similarities.keyword ?= []
      similarities.keyword = similarities.keyword.filter (v) ->
        return v.id != opponent.id
      similarities.keyword.push {id: opponent.id, value: similarity}
      user.profile.similarities = similarities
      user.profile.good_users = []
      user.profile.good_users.push goodUser(similarities.keyword)
      console.log user.profile.good_users
      return user
    @getUsers (users)=>
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
        @finishCallback()
      async.eachSeries users, iterateUser, finishUser
User.find().exec (err, users)->
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
