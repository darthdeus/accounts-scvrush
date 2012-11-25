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
    var key = localStorage.getItem("client_key");
    return (key === "null") ? null : key;
  };

  var _restored = function(err, res) {
    if (err) throw err;
    _restoreSession(res);
    Meteor.call("connected", _localId());
  };

  Meteor.call("restoreSession", _localId(), _restored);

  var _isAdminCallback = function(err, value) {
    Session.set("is_admin", value);
  };

  Scvrush.isAdmin = function(force) {
    if (!Session.get("is_admin") || force) {
      Meteor.call("isAdmin", _localId(), _isAdminCallback);
    }

    return Session.get("is_admin");
  };

  Scvrush.username = function() {
    debugger
    var data = _session();

    if (data && data.user_data) {
      return data.user_data.username;
    } else {
      return null;
    }
  };

  var _authenticated = function(err, res) {
    if (res === -1) {
      // TODO - user is banned
    } (res === false) {
      // TODO - authentication failed
    } else {
      _setLocalId(res.client_key);
      _restoreSession(res);
      Scvrush.isAdmin();
    }
  };

  var _logout = Scvrush.logout = function() {
    _setLocalId(null);
    _restoreSession(null);
    Meteor.call("logout");
    Scvrush.isAdmin(true);
  };

  Template.scvrushLogin.isLogged = function() {
    return !!_session();
  };

  Template.scvrushLogin.username = Scvrush.username;

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

