Package.describe({
  summary: "Login service for Scvrush accounts"
});

Package.on_use(function(api) {
  api.use('accounts-base', ['client', 'server']);
  api.use('http', ['client', 'server']);
  api.use('templating', 'client');
  api.use('localstorage-polyfill', 'client');

  api.add_files(
    ['scvrush_login.html', 'scvrush_configure.js'],
    'client');

  api.add_files('scvrush_common.js', ['client', 'server']);
  api.add_files('scvrush_server.js', 'server');
  api.add_files('scvrush_client.js', 'client');
});
