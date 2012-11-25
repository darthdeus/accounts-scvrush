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
  # Generate a new client key and delete all
  # previously paired client keys
  #
  # Returns the new client_key
  _generateclient_key = (api_key) ->
    UserKeys.remove api_key: api_key
    uuid = Meteor.uuid()

    UserKeys.insert
      api_key: api_key
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
        return Scvrush.DB.credentialsValid(api_key)
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
