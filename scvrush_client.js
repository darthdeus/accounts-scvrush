(function () {
  var _authenticated = function(err, res) {
    var data = JSON.stringify(res);
    localStorage.setItem("user_session", data);
    Session.set("user_session", data);
  };

  var _logout = function() {
    localStorage.setItem("user_session", null);
    Session.set("user_session", null);
    console.log('logged out');
  };

  Template.scvrushLogin.isLogged = function() {
    return !!Session.get("user_session");
  };

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

  Session.set("user_session", localStorage.getItem("user_session"));
})();
