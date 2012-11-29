@Scvrush ||= {}
Scvrush.DB ||= {}

# Create a new client key for a user who just
# logged in and received his API key.
#
# Also updates his user data with profile information
# from the main profile.
Scvrush.DB.createKeyWithData = (api_key) ->
  clientKey = Scvrush.DB.generateClientKey(api_key)
  userData  = Scvrush.API.fetchData(api_key)
  Scvrush.DB.updateKeyWithData clientKey, userData

  return {
    client_key: clientKey
    user_data:  userData
  }

# Generate new client key and assign it to a given API key
Scvrush.DB.generateClientKey = (api_key) ->
  UserKeys.remove api_key: api_key
  client_key = Meteor.uuid()
  UserKeys.insert api_key: api_key, client_key: client_key

  return client_key

Scvrush.DB.updateKeyWithData = (clientKey, userData) ->
  # TODO - fetch the admin flag from API instead
  update_attributes = $set: { admin: true , data: userData }

  UserKeys.update client_key: clientKey, update_attributes

Scvrush.DB.isBanned = (username) ->
  ban = Bans.findOne username: username
  console.log "trying to check #{username} if user", ban, "is banned", new Date().getTime()

  result = ban?.banned_until > new Date().getTime()
  console.log "user #{username} is banned" if result

  return result

Scvrush.DB.loadDataIfNotBanned = (username, api_key) ->
  if Scvrush.DB.isBanned(username, api_key)
    return -1
  else
    return Scvrush.DB.createKeyWithData(api_key)

Scvrush.DB.ban = (username) ->
  end_time = new Date().getTime() + 1000 * 60 * 5

  Bans.remove username: username
  Bans.insert username: username, banned_until: end_time

  console.log "banned #{username} until", new Date(end_time)