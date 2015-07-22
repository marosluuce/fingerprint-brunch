"use strict"

fs      = require 'fs'
pathlib = require 'path'
getHash = require('../lib/hash');

warn = (message) -> Fingerprint.logger.warn "brunch-hash WARNING: #{message}"

class Fingerprint
  brunchPlugin: true


  constructor: (@config) ->
    # Defaults options
    @options = {
      # Mapping file so your server can serve the right files
      manifest: './assets.json'
      # The base Path you want to remove from the `key` string in the mapping file
      srcBasePath: 'exemple/'
      # The base Path you want to remove from the `value` string in the mapping file
      destBasePath: 'out/'
      # Set to true if you don't want to keep folder structure in the `key` value in the mapping file
      flatten: false
      # How many digits of the SHA1.
      hashLength: 8
    }

    # Merge config
    cfg = @config.plugins?.fingerprint ? {}
    @options[k] = cfg[k] for k of cfg

    # Get files
    jsFileToHash = @config.files?.javascripts ?.joinTo ? {}
    cssFileToHash = @config.files?.stylesheets ?.joinTo ? {}

  teardown: ->
    map = {}
    mappingExt = path.extname(options.manifest);

    # Get Hash
    hash = getHash source, 'utf8'
    hash = hash.substr 0, options.hashLength

    

    # write manifest
    if options.manifest
      output = ''

      if mappingExt === '.php'
        output = "<?php return json_decode('" + JSON.stringify map + "'); ?>"
      else
        output = JSON.stringify map, null, "  "

      fs.writeFileSync(@options.manifest, output)
  

Fingerprint.logger = console

module.exports = BrunchHashPlugin
