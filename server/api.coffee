@Scvrush ||= {}
Scvrush.API ||= {}

# Try to authenticate the user against SCV Rush REST API.
#
# Returns the user's API key on success, otherwise `false`
Scvrush.API.authenticate = (login, password) ->
  query    = "username=#{login}&password=#{password}"
  response = Meteor.http.get "http://scvrush.com/api/auth.json", query: query

  if response.statusCode == 200
    return response.data.key
  else
    return false

Scvrush.API.fetchData = (apiKey) ->
  query = "api_key=#{apiKey}"
  response = Meteor.http.get "http://scvrush.com/api/user_data.json", query: query

  if response.statusCode == 200
    return response.data
  else
    throw new Meteor.Error(404, "User data not found for API key #{apiKey}")

