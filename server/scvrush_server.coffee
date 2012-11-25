@Scvrush ||= {}

Scvrush.isAdmin = (clientKey) ->
  user = UserKeys.findOne(client_key: clientKey)
  user && !!user.admin


# Returns username for a given client key,
# or null if none found.
Scvrush.usernameForKey = (clientKey) ->
  user_info = UserKeys.findOne(client_key: clientKey)
  if user_info and user_info.data
    user_info.data.username
  else
    null

UserKeys = new Meteor.Collection("user_keys")

# Scvrush.DB.generateClientKey = (apiKey) ->

do ->
  # Generate a new client key and delete all
  # previously paired client keys
  #
  # Returns the new client_key
  _generateClientKey = (apiKey) ->
    UserKeys.remove api_key: apiKey
    uuid = Meteor.uuid()

    UserKeys.insert
      api_key: apiKey
      client_key: uuid

    uuid

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
        if Scvrush.DB.isBanned(api_key)
          return -1
        else
          user_info = Scvrush.DB.createKeyWithData(apiKey)

        @setUserId user_info.client_key

        return user_info

      else
        return false

    restoreSession: (clientKey) ->
      user_data = UserKeys.findOne(client_key: clientKey)
      if user_data
        @setUserId clientKey

        return {
          client_key: user_data.client_key
          user_data:  user_data.data
        }

      else
        null

    isAdmin: (clientKey) ->
      Scvrush.isAdmin clientKey
