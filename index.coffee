config = require "config"
console.log "load config", JSON.stringify config, "\n"

http = require "http"
express = require "express"
session = require "express-session"
MongoStore = require("connect-mongo")(session)
bodyParser = require "body-parser"
cookieParser = require "cookie-parser"
logger = require "morgan"

passport = require "passport"
HatenaStrategy = require("passport-hatena").Strategy

mongoose = require "mongoose"
mongoose.connect "mongodb://#{config.mongodb.host}/#{config.mongodb.db}"
{User} = require "./models/user"


passport.serializeUser (user, done) ->
  done null, user.id
passport.deserializeUser (id, done) ->
  user =
    id: id
  done null, user
  #User.findOne {uid:uid}, (err, user) ->
  #  done err, user
passport.use new HatenaStrategy
  consumerKey: config.hatena.consumerKey
  consumerSecret: config.hatena.consumerSecret
  callbackURL: config.hatena.callbackURL
  , (token, tokenSecret, profile, done) ->
    console.log profile
    passport.session.token = token
    return done(null, profile)
    #User.loginOrRegisterHatena token, tokenSecret, profile, done

app = express()
app.use logger "dev"
app.use bodyParser()
app.set "views", __dirname + '/views'
app.set "view engine", "jade"
app.use "/static", express.static 'static'
app.use cookieParser(config.cookie.secret)
app.use session
  secret: config.session.secret
  store: new MongoStore({db: config.mongodb.db})
app.use passport.initialize()
app.use passport.session()

app.get "/auth/hatena",
  passport.authenticate "hatena", { scope: ['read_public'] }
app.get "/auth/hatena/callback",
  passport.authenticate "hatena",
    failureRedirect: "/"
    successRedirect: "/home"

app.get "/", (req, res) ->
  res.render "index", {pretty:true}

app.get "/users", (req, res) ->
  User.find {}, {}, {sort:{id:1}}, (err, users) ->
    if err?
      console.log err
      res.send 500, "Error"
    if users?
      res.render "users", {pretty:true, users:users}

app.get "/user/:id", (req, res) ->
  User.findOne {id:req.params.id}, (err, user) ->
    if err?
      console.log err
      res.send 500, "Error"
    if user?
      res.render "user", {pretty:true, user:user}
    else
      res.send 404, "NotFound"

if not module.parent
  server = http.createServer(app).listen(config.port)
  console.log "#{new Date()}, app start #{config.port}"


