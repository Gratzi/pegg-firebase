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
#        timestamp: req.body.timestamp
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

  try
    for friendId in req.body.friends
      firebase.child("inbound/#{friendId}").push {
        timestamp: req.body.timestamp
        type: 'friendsUpdate'
        friendId: req.body.userId
      }, (error) => fail error if error?
    firebase.child("inbound/#{req.body.userId}").push {
      timestamp: req.body.timestamp
      type: 'friendsUpdate'
    }, (error) => fail error if error?
    res.send msg
  catch error
    fail error

module.exports = router
