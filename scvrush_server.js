if (typeof Scvrush === "undefined") Scvrush = {};

// Authenticate credentials against the API
Scvrush.authenticate = function(login, password) {
  var query = "username=" + login + "&password=" + password;

  var response = Meteor.http.get("http://scvrush.com/api/auth.json", { query: query });
  return response;
};

// Fetch user data with the API key
Scvrush.userData = function(apiKey) {
  var query = "api_key=" + apiKey;

  var response = Meteor.http.get("http://scvrush.com/api/user_data.json", { query: query });
  return response;
};

UserKeys = new Meteor.Collection("user_keys");

(function() {

  // Generate a new client key and delete all
  // previously paired client keys
  //
  // Returns the new client_key
  var _generateClientKey = function(apiKey) {
    UserKeys.remove({api_key: apiKey});

    var uuid = Meteor.uuid();
    UserKeys.insert({api_key: apiKey, client_key: uuid});
    return uuid;
  };

  var _updateKeyWithData = function(clientKey, userData) {
    UserKeys.update({client_key: clientKey}, {$set: { data: userData }});
  };

  var _authenticated = function(response) {
    if (response.statusCode === 200) {
      return _authenticationSuccessful(response.data.key);
    } else {
      return _authenticationFailed();
    }
  };

  var _fetchUserData = function(apiKey) {
    var response = Scvrush.userData(apiKey);
    if (response.statusCode === 200) {
      return response.data;
    } else {
      throw new Meteor.Error(404, "user data not found");
    }
  };

  var _authenticationSuccessful = function(apiKey) {
    var clientKey = _generateClientKey(apiKey);
    var userData  = _fetchUserData(apiKey);

    _updateKeyWithData(clientKey, userData);

    return { client_key: clientKey, user_data: userData };
  };

  var _authenticationFailed = function() {
    console.log("Authentication failed");
    return null;
  };

  // var _dataForClientKey()

  Meteor.methods({
    authenticate: function(login, password) {
      var response = Scvrush.authenticate(login, password);
      response = _authenticated(response);

      this.setUserId(response.client_key);
      console.log("user id set to ", response.client_key);

      return response;
    },

    restoreSession: function(clientKey) {
      var user_data = UserKeys.findOne({client_key: clientKey});

      if (user_data) {
        return { client_key: user_data.client_key, user_data: user_data.data };
      } else {
        return null;
      }

    }
  });

})()

