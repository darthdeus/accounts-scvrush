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

Scvrush.DB.isBanned = (api_key) ->
  false

Scvrush.DB.credentialsValid = (api_key) ->
  if Scvrush.DB.isBanned(api_key)
    return -1
  else
    return Scvrush.DB.createKeyWithData(api_key)
