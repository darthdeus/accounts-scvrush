@Scvrush ||= {}
Scvrush.Session ||= {}

Scvrush.Session =
  session: ->
    return Session.get "user_session"

  restoreSession: (data) ->
    Session.set "user_session", data

  setLocalId: (client_key) ->
    localStorage.setItem "client_key", client_key

  clientKey: ->
    key = localStorage.getItem "client_key"
    return if key == "null" then null else key

  restored: (err, res) ->
    throw err if err
    Scvrush.Session.restoreSession(res)
    Meteor.call "connected", Scvrush.Session.clientKey()

Meteor.startup ->
  Meteor.call "restoreSession", Scvrush.Session.clientKey(), Scvrush.Session.restored

_isAdminCallback = (err, value) ->
  Session.set "is_admin", value

Scvrush.isAdmin = (force) ->
  if !Session.get("is_admin") || force
    Meteor.call "isAdmin", Scvrush.Session.clientKey(), _isAdminCallback

  Session.get "is_admin"

Scvrush.username = ->
  data = Scvrush.Session.session()
  if data && data.user_data
    data.user_data.username
  else
    null

Scvrush.authenticated = (err, res) ->
  if res == -1
    alert "You are banned."
    # TODO - user is banned
  else if res == false
    alert "Wrong login/password."
    # TODO - authentication failed
  else
    Scvrush.Session.setLocalId(res.client_key)
    Scvrush.Session.restoreSession(res)
    Scvrush.isAdmin()

Scvrush.logout = ->
  Scvrush.Session.setLocalId(null)
  Scvrush.Session.restoreSession(null)
  Meteor.call "logout"
  Scvrush.isAdmin(true)

Template.scvrushLogin.isLogged = ->
  !!Scvrush.Session.session()

Template.scvrushLogin.username = Scvrush.username
Template.scvrushLogin.events =
  "submit form": (event) ->
    event.preventDefault()
    login    = $(event.target).find("[name=login]").val()
    password = $(event.target).find("[name=password]").val()

    Meteor.call "authenticate", login, password, Scvrush.authenticated

  "click .logout": (event) ->
    event.preventDefault()
    Scvrush.logout()