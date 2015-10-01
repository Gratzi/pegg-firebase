debug = require 'debug'
log = debug 'app:log'
error = debug 'app:error'
fail = (msg) ->
  error msg
  throw new Error msg

Firebase = require 'firebase'
FirebaseTokenGenerator = require 'firebase-token-generator'

FIREBASE_SECRET = process.env.FIREBASE_SECRET or fail "cannot have an empty FIREBASE_SECRET"

class PeggFirebaseClient extends Firebase
  constructor: ->
    super 'https://pegg.firebaseio.com'
    tokenGenerator = new FirebaseTokenGenerator FIREBASE_SECRET
    token = tokenGenerator.createToken {uid: '18784545'}#, {admin: true, expires: 2272147200}
    @authWithCustomToken token, (error, auth) =>
      if error?
        error error, auth
      else
        log 'Login to Firebase successful'

module.exports = new PeggFirebaseClient