express = require 'express'
router = express.Router()
Firebase = require 'firebase'
FirebaseTokenGenerator = require 'firebase-token-generator'

firebase = new Firebase 'https://pegg.firebaseio.com'
tokenGenerator = new FirebaseTokenGenerator process.env.FIREBASE_SECRET
token = tokenGenerator.createToken {uid: '18784545'}#, {admin: true, expires: 2272147200}
console.log token
firebase.authWithCustomToken token, (error, auth) =>
  if error?
    console.log error, auth

### GET home page. ###
router.get '/', (req, res) ->
  res.render 'index', title: 'Express'


### New Card Created ###
router.post '/card', (req, res) ->
# req.body:
#  userId: 'asdasd'
#  friends: ['asd','qwe']
#  cardId: '123123'
#  dts: 'someDate'

  for friendId in req.body.friends
    firebase.child("#{friendId}/created.json").update
      "#{req.body.cardId}":
        userId: req.body.userId
        dts: req.body.dts

### New User Created ###
router.get '/user', (req, res) ->
  res.render 'index', title: 'Express'


module.exports = router
