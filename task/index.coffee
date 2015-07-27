"use strict"

fs       = require 'fs'
path     = require 'path'
getHash  = require '../lib/hash'


warn = (message) -> Fingerprint.logger.warn "fingerprint-brunch WARNING: #{message}"

class Fingerprint
  brunchPlugin: true


  constructor: (@config) ->
    # Defaults options
    @options = {
      # Mapping file so your server can serve the right files
      manifest: './assets.json'
      # Pattern for identify all files to change
      pattern: '_fingerprint_'
      # The base Path you want to remove from the `key` string in the mapping file
      srcBasePath: 'exemple/'
      # The base Path you want to remove from the `value` string in the mapping file
      destBasePath: 'out/'
      # Set to true if you don't want to keep folder structure in the `key` value in the mapping file
      flatten: false
      # How many digits of the SHA1.
      hashLength: 8
      # Files you want to hash
      targets: []
    }

    # Merge config
    cfg = @config.plugins?.fingerprint ? {}
    @options[k] = cfg[k] for k of cfg


  onCompile: (generatedFiles) ->
    map = {}
    mappingExt = path.extname(@options.manifest);

    @_makeCoffee(generatedFiles, map, _writeManifest)


  _makeCoffee: (file, digestMap, callback) ->
    # Open files
    for file in generatedFiles
      fs.readFile file.path, 'utf8', (err,data) ->
        # Generate hash
        hash = getHash data, 'utf8'

        # Generate the new path (with new filename)
        dir = path.dirname(file.path)
        ext = path.extname(file.path)
        base = path.basename(file.path, ext)
        newName = "#{base}-#{hash}#{ext}"
        newFileName = path.join(dir, newName)

        # Add link to map
        digestMap[file.path] = newFileName

        # Create new file, with hash
        fs.writeFileSync(newFileName, data)

    @callback(digestMap)
      


  _writeManifest: (digestMap) ->
    console.log digestMap
    output = JSON.stringify digestMap, null, "  "
    fs.writeFileSync(@options.manifest, output)

Fingerprint.logger = console

module.exports = Fingerprint
