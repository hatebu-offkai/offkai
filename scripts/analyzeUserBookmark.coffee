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
    @analyzeUserBookmarks =>
      @analyzeUserSimilarity =>
        @finishCallback()
  analyzeUserBookmarks: (callback)->
    UserBookmark.find({user:@user},{entry:true,tags:true}).exec (err, userBookmarks) =>
      if err?
        console.log err
        @finishCallback()
        return
      async.applyEach [@countBookmarksTags, @analyzeBookmarkEntries], userBookmarks, ->
        callback()
  analyzeBookmarkEntries: (userBookmarks, callback)=>
    # userBookmarks から entry._id だけの配列を作って find する
    entries = _.map userBookmarks, (r)->r.entry
    BookmarkEntry.find(_id:{$in:entries}).exec (err, bookmarks)=>
      if err?
        console.log err
        @finishCallback()
        return
      async.applyEach [@countBookmarksCategory, @countBookmarksHatenaKeywords, @countBookmarksTitleWords], bookmarks, ->
        callback()
  analyzeUserSimilarity: (callback)->
    User.find({_id:{$ne:@user._id}}).exec (err, users) =>
      if err?
        console.log err
        @finishCallback()
        return
      async.applyEach [@calculateKeywordSimilarity], users, ->
        callback()
  countBookmarksTags: (userBookmarks, callback)=>
    tags = _.flatten _.map userBookmarks, (r)->r.tags
    tagCounter = {}
    _.map tags, (t)->
      if tagCounter[t]?
        tagCounter[t]++
      else
        tagCounter[t]=1
    counting = _.map tagCounter, (v,k)->[k,v]
    counting = counting.sort (a, b)->b[1] - a[1]
    counted = _.map counting, (e)->{word:e[0], count:e[1]}
    #console.log counted
    @user.profile.tags = counted
    @user.save ->
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
  countWordArray: (wordArray, counter)->
    _.map wordArray, (word)->
      if counter[word]?
        counter[word]++
      else
        counter[word]=1
  sortWordCounter: (counter)->
    counted = _.map counter, (v,k)->[k,v]
    counted.sort (a, b)->b[1] - a[1]
    counted = counted.slice(0, 19)
    counted = _.map counted, (e)->{word:e[0], count:e[1]}
    return counted
  countBookmarksHatenaKeywords: (bookmarks, callback)=>
    counter = {}
    iterateBookmark = (b, done) =>
      @countWordArray(b.hatena_keywords, counter)
      done()
    finishBookmark = (err) =>
      counted = @sortWordCounter(counter)
      @user.profile.keywords = counted
      @user.save =>
        callback()
    async.eachSeries bookmarks, iterateBookmark, finishBookmark
  countBookmarksTitleWords: (bookmarks, callback)=>
    counter = {}
    iterateBookmark = (b, done) =>
      @countWordArray(b.title_words, counter)
      done()
    finishBookmark = (err) =>
      counted = @sortWordCounter(counter)
      @user.profile.titles = counted
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
      result = product / (magA * magB)
      result = 0 if isNaN result
      return result
    updateUserSimilarities = (user, opponent, similarity, type) ->
      similarities = user.profile.similarities ? {}
      similarities[type] ?= []
      similarities[type] = similarities[type].filter (v) ->
        return v.id != opponent.id
      similarities[type].push {id: opponent.id, value: similarity}
      user.profile.similarities = similarities
      return user
    iterateUser = (u, done) =>
      if u.profile.keywords?
        categorySimilarity = cosineSimilarity @user.profile.categories, u.profile.categories
        keywordSimilarity = cosineSimilarity @user.profile.keywords, u.profile.keywords
        titleSimilarity = cosineSimilarity @user.profile.titles, u.profile.titles
        tagSimilarity = cosineSimilarity @user.profile.tags, u.profile.tags
        for set in [['category', categorySimilarity], ['keyword', keywordSimilarity], ['title', titleSimilarity], ['tag', tagSimilarity]]
          @user = updateUserSimilarities @user, u, set[1], set[0]
          u = updateUserSimilarities u, @user, set[1], set[0]
        @user.save (err) =>
          u.save done()
      else
        done()
    finishUser = (err) =>
      for type in ['category', 'keyword', 'title', 'tag']
        similarity = @user.profile.similarities[type]
        sorting = _.map similarity, (e)-> [e.id, e.value]
        sorting.sort (a,b)->b[1] - a[1]
        sorted = _.map sorting, (e)->{id:e[0], value:e[1]}
        #console.log sorted
        @user.profile.similarities[type] = sorted
      @user.save =>
        callback()
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
