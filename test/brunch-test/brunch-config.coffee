exports.config =
  paths:
    public: './public'
    compass: './config.rb'
    watched: ['app']

  files:
    javascripts:
      joinTo:
        # Main
        '/js/master.js': /^(bower_components[\/\\]jquery|app)/

    stylesheets:
      joinTo:
        '/css/master.css': /^(app)/

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
      manifest: '../app/config/assets/assets.json'
      srcBasePath: '../public/'
      destBasePath: '../public/'
      autoClearOldFiles: true
      targets: ['master.js','master.css']
      environments: ['production']
      alwaysRun: false