if (typeof Scvrush === "undefined") Scvrush = {};

(function () {
  var _session = function() {
    return Session.get("user_session");
  };

  var _restoreSession = function(data) {
    Session.set("user_session", data);
  };

  var _setLocalId = function(id) {
    localStorage.setItem("client_key", id);
  };

  var _localId = Scvrush.clientKey = function() {
    return localStorage.getItem("client_key");
  };

  var _restored = function(err, res) {
    if (err) throw err;
    _restoreSession(res);
  };

  Meteor.call("restoreSession", _localId(), _restored);

  Accounts.scvrush.username = function() {
    var data = _session();

    if (data && data.user_data) {
      return data.user_data.username;
    } else {
      return null;
    }
  };

  var _authenticated = function(err, res) {
    _setLocalId(res.client_key);
    _restoreSession(res);
  };

  var _logout = function() {
    _setLocalId(null);
    _restoreSession(null);
  };

  Template.scvrushLogin.isLogged = function() {
    return !!_session();
  };

  Template.scvrushLogin.username = Accounts.scvrush.username;

  Template.scvrushLogin.events = {
    "submit form": function(event) {
      event.preventDefault();
      var login    = $(event.target).find("[name=login]").val(),
          password = $(event.target).find("[name=password]").val();

      Meteor.call("authenticate", login, password, _authenticated);
    },

    "click .logout": function(event) {
      event.preventDefault();
      _logout();
    }
  };

})();

