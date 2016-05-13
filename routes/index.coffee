debug = require 'debug'
log = debug 'app:log'
errorLog = debug 'app:error'
fail = (err) ->
  if typeof err is 'string'
    err = new Error err
  errorLog err
  throw err

express = require 'express'
firebase = require '../lib/pegg-firebase-client'
router = express.Router()

validateClient = (secret) ->
  if secret isnt CLIENT_SECRET
    fail "invalid client secret, aborting"

CLIENT_SECRET = process.env.CLIENT_SECRET or fail "cannot have an empty CLIENT_SECRET"

### GET home page. ###
router.get '/', (req, res) ->
  res.render 'index', title: 'Express'


#### New Card Created ###
#router.post '/newCard', (req, res) ->
#  validateClient req.body.secret
#  req.body.secret = undefined
#
#  for friendId in req.body.friends
#    firebase.child(friendId).child('newCard').update
#      "#{req.body.cardId}":
#        userId: req.body.userId
#        dts: req.body.dts
#
#  msg = "submitting new card notification to firebase: "+ JSON.stringify req.body
#  log msg
#  res.send msg

### New User Created ###
router.post '/newUser', (req, res) ->
  validateClient req.body.secret
  req.body.secret = undefined

  msg = "submitting new user notification to firebase: "+ JSON.stringify req.body
  log msg

  for friendId in req.body.friends
    firebase.child('inbound').child(friendId).push {
      dts: req.body.dts
      type: 'friendsUpdate'
      friendId: req.body.userId
    }, (error) => fail error if error?
  firebase.child('inbound').child(req.body.userId).push {
    dts: req.body.dts
    type: 'friendsUpdate'
  }, (error) => fail error if error?

  res.send msg

module.exports = router
