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
    chopUrl = chopUrl.replace(/#/, "%23")
    bookmarkInfoUrl = baseUrl+chopUrl
    console.log "request", bookmarkInfoUrl
    request bookmarkInfoUrl, (err, resp, body) =>
      if !err && resp.statusCode == 200
        $ = cheerio.load body
        @parseBookmarkInfo $
      else
        console.log "error", err
        @finishCallback()
  parseBookmarkInfo: ($) ->
    count = $("ul.entry-page-unit li.entry-unit ul.users li strong a span").text()
    category = $("ul.entry-page-unit > li > div.entry-contents > ul.entry-data > li.category > a").text()
    keywords = []
    $("a.keyword").each (idx, elem) ->
      k = $(elem).text()
      if keywords.indexOf(k)==-1
        keywords.push k
    timestamp = Date.parse $("ul.entry-page-unit > li > div.entry-contents > ul.entry-data > li.date").text()
    @entry.bookmark_count = count
    @entry.category = category
    @entry.hatena_keywords = keywords
    @entry.timestamp = timestamp
    console.log @entry
    @entry.save(@finishCallback)

BookmarkEntry.find {timestamp:{$exists:false}}, {}, {limit:0}, (err, entries) ->
  iterate = (entry, done) ->
    scraper = new EntryPageScraper entry
    scraper.run(done)
  finish = (err) ->
    mongoose.connection.close()
    process.exit()
  async.eachSeries entries, iterate, finish
