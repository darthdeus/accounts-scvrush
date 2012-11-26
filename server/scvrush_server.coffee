@Scvrush ||= {}

Scvrush.isAdmin = (client_key) ->
  user = UserKeys.findOne(client_key: client_key)
  user && !!user.admin

# Returns username for a given client key,
# or null if none found.
Scvrush.usernameForKey = (client_key) ->
  user_info = UserKeys.findOne(client_key: client_key)
  if user_info and user_info.data
    user_info.data.username
  else
    null

UserKeys = new Meteor.Collection("user_keys")

# Scvrush.DB.generateclient_key = (api_key) ->

do ->
  _authenticated = (response) ->
    if response.statusCode is 200
      _authenticationSuccessful response.data.key
    else
      _authenticationFailed()

  _authenticationFailed = ->
    console.log "Authentication failed"
    null

  Meteor.methods
    # Authenticate the user against the API
    authenticate: (login, password) ->
      api_key = Scvrush.API.authenticate(login, password)

      if api_key
        user_info = Scvrush.DB.credentialsValid(api_key)
        @setUserId user_info.client_key
        return user_info
      else
        return false

    restoreSession: (client_key) ->
      user_data = UserKeys.findOne(client_key: client_key)

      if user_data
        @setUserId client_key

        return {
          client_key: user_data.client_key
          user_data:  user_data.data
        }
      else
        null

    isAdmin: (client_key) ->
      Scvrush.isAdmin client_key
