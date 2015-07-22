"use strict"

crypto  = require 'crypto'
fs      = require 'fs'
getHash = require('../lib/hash');

warn = (message) -> BrunchHashPlugin.logger.warn "brunch-hash WARNING: #{message}"

class BrunchHashPlugin
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
    cfg = @config.plugins?.digest ? {}
    @options[k] = cfg[k] for k of cfg


  onCompile: (generatedFiles) ->
    BrunchHashPlugin.logger.log generatedFiles
	  #@_writeManifestFile(replacementDigestMap)
#
#    #mappingExt = path.extname(options.mapping);
#
#    #if options.mapping
#    #  output = ''
#
#    #  if mappingExt === '.php'
#    #    output = "<?php return json_decode('" + JSON.stringify map + "'); ?>"
#    #  else
    #    output = JSON.stringify map, null, "  "


  _writeManifestFile: (renameMap) ->
    if not @options.manifest
      return
    manifest = {}
    for file, hash of renameMap when hash
      relative = pathlib.relative(@publicFolder, file)
      rename = @_addHashToPath relative, hash
      manifest[relative] = rename
    fs.writeFileSync(@options.manifest, JSON.stringify(manifest, null, 4))


BrunchHashPlugin.logger = console

module.exports = BrunchHashPlugin
