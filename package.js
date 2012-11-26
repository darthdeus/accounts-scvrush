Package.describe({
  summary: "Login service for Scvrush accounts"
});

Package.on_use(function(api) {
  api.use('accounts-base', ['client', 'server']);
  api.use('http', ['client', 'server']);
  api.use('templating', 'client');
  api.use('localstorage-polyfill', 'client');
  api.use('coffeescript', ['client', 'server']);

  api.add_files(
    ['scvrush_login.html', 'scvrush_configure.js'],
    'client');

  api.add_files('scvrush_common.js', ['client', 'server']);

  api.add_files('server/api.coffee',            'server');
  api.add_files('server/db.coffee',             'server');
  api.add_files('server/scvrush_server.coffee', 'server');

  // api.add_files('scvrush_client.js', 'client');
  api.add_files('client/session.coffee', 'client');
});
