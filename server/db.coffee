@Scvrush ||= {}
Scvrush.DB ||= {}

# Create a new client key for a user who just
# logged in and received his API key.
#
# Also updates his user data with profile information
# from the main profile.
Scvrush.DB.createKeyWithData = (apiKey) ->
  clientKey = Scvrush.DB.generateClientKey(apiKey)
  userData  = Scvrush.API.fetchData(apiKey)
  Scvrush.DB.updateKeyWithData clientKey, userData

  return {
    client_key: clientKey
    user_data:  userData
  }

# Generate new client key and assign it to a given API key
Scvrush.DB.generateClientKey = (apiKey) ->
  UserKeys.remove api_key: apiKey

  uuid = Meteor.uuid()
  UserKeys.insert api_key: apiKey, client_key: uuid
  uuid

Scvrush.DB.updateKeyWithData = (clientKey, userData) ->
  # TODO - fetch the admin flag from API instead
  update_attributes = $set: { admin: true , data: userData }

  UserKeys.update client_key: clientKey, update_attributes
