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
  run: (done) ->
    @finishCallback = done
    @getBookmarkInfo()
  getBookmarkInfo: (done) ->
    chopUrl = @entry.url.replace(/https?:\/\//, "")
    bookmarkInfoURL = "http://b.hatena.ne.jp/entry/"+chopUrl
    request bookmarkInfoURL, (err, resp, body) =>
      if !err && resp.statusCode == 200
        $ = cheerio.load body
        @parseBookmarkInfo url, $
  parseBookmarkInfo: (url, $, done) ->
    data =
      count: $("ul.entry-page-unit li.entry-unit ul.users li strong a span").text()
      category: $(".entry-contents ul.entry-data li.category a").text()
      keywords: $("a.keyword")
    console.log data

BookmarkEntry.find {}, {}, {limit:1} (err, entries) ->
  iterate (entry, done) ->
    scraper = new EntryPageScraper entry
    scraper.run(done)
  finish (err) ->
    mongoose.connection.close()
    process.exit()
  async.eachSeries entries, iterate, finish
