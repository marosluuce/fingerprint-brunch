"use strict"

fs       = require 'fs'
path     = require 'path'
crypto   = require 'crypto'

warn = (message) -> Fingerprint.logger.warn "fingerprint-brunch WARNING: #{message}"

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
      # How many digits of the SHA1.
      hashLength: 8
      # Files you want to hash, default is all else put an array of files like ['app.js', 'vendor.js', ...]
      targets: '*'
    }

    # Merge config
    cfg = @config.plugins?.fingerprint ? {}
    @options[k] = cfg[k] for k of cfg


  onCompile: (generatedFiles) ->
    map = {}

    # Open files
    for file in generatedFiles
      #  # Generate the new path (with new filename)
      dir = path.dirname(file.path)
      ext = path.extname(file.path)
      base = path.basename(file.path, ext)

      if @options.targets == '*' or (base + ext) in @options.targets
        hash = null
        # Generate hash
        data = fs.readFileSync file.path
        shasum = crypto.createHash 'sha1'
        shasum.update(data)
        hash = shasum.digest('hex')[0..@options.hashLength-1]

        # Make new good path
        newName = "#{base}-#{hash}#{ext}"
        newFileName = path.join(dir, newName)

        # Rename file, with hash
        fs.renameSync(file.path, newFileName)
        
        # Add link to map
        keyPath = file.path.replace @options.srcBasePath, ""
        realPath = newFileName.replace @options.destBasePath, ""
        map[keyPath] = realPath

    output = JSON.stringify map, null, "  "
    fs.writeFileSync(@options.manifest, output)
    

Fingerprint.logger = console

module.exports = Fingerprint
