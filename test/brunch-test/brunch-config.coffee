exports.config =
  paths:
    public: './public'
    watched: ['app']

  files:
    javascripts:
      joinTo:
        # Main
        '/master.js': /^(bower_components[\/\\]jquery|app)/

    stylesheets:
      joinTo:
        '/master.css': /^(app)/

  modules:
    wrapper: false
    definition: false

  conventions:
    # we don't want javascripts in asset folders to be copied like the one in
    # the bootstrap assets folder
    assets: /assets[\\/](?!javascripts)/

  plugins:
    cleancss:
      keepSpecialComments: 0
      removeEmpty: true
    sass:
      debug: 'comments'
      allowCache: true
    fingerprint:
      manifest: 'assets.json'
      srcBasePath: '../public/'
      destBasePath: '../public/'
      autoClearOldFiles: true
      targets: ['master.js','master.css']
      environments: ['production']
      alwaysRun: true