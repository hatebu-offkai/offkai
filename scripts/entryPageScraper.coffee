config = require "config"
mongoose = require "mongoose"
connection = mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
bookmarkModel = require "../models/bookmark"
BookmarkEntry = bookmarkModel.BookmarkEntry

request = require "request"
cheerio = require "cheerio"
xml2js = require "xml2js"
async = require "async"

class EntryPageScraper
  constructor: (@entry)->
    console.log @entry.url
  run: (done) ->
    @finishCallback = done
    @getBookmarkInfo()
  getBookmarkInfo: () ->
    baseUrl = "http://b.hatena.ne.jp/entry/"
    if @entry.url.match(/^https/)
      baseUrl = baseUrl+"s/"
    chopUrl = @entry.url.replace(/https?:\/\//, "")
    bookmarkInfoUrl = baseUrl+chopUrl
    console.log "request", bookmarkInfoUrl
    request bookmarkInfoUrl, (err, resp, body) =>
      if !err && resp.statusCode == 200
        $ = cheerio.load body
        @parseBookmarkInfo $
      else
        console.log "error", err, resp.statusCode
        @finishCallback()
  parseBookmarkInfo: ($) ->
    data =
      count: $("ul.entry-page-unit li.entry-unit ul.users li strong a span").text()
      category: $(".entry-contents ul.entry-data li.category a").text()
      keywords: $("a.keyword")
    console.log @entry.url, @entry.title
    console.log data
    @finishCallback()

BookmarkEntry.find {}, {}, {limit:1}, (err, entries) ->
  iterate = (entry, done) ->
    scraper = new EntryPageScraper entry
    scraper.run(done)
  finish = (err) ->
    mongoose.connection.close()
    process.exit()
  async.eachSeries entries, iterate, finish
