@Scvrush ||= {}

UserKeys = new Meteor.Collection("user_keys")
Bans     = new Meteor.Collection("bans")

Meteor.publish "bans", ->
  username = Scvrush.usernameForKey(@userId)
  where =
    banned_until: { $gt: new Date().getTime() },
    username: username

  Bans.find where, { sort: { created_at: 1 } }

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
    authenticate: (username, password) ->
      api_key = Scvrush.API.authenticate(username, password)

      if api_key
        try
          user_info = Scvrush.DB.loadDataIfNotBanned(username, api_key)
          console.log "fetched user info", user_info

          @setUserId user_info.client_key
          return user_info

        catch ban
          return status: "ban", ban: ban
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

    ban: (username) ->
      if Scvrush.isAdmin @userId
        Scvrush.DB.ban username
        console.log "banned #{username}"
      else
        console.log "unauthorized ban"
        # TODO - throw unauthorized exception

    isAdmin: (client_key) ->
      Scvrush.isAdmin client_key
