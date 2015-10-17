"use strict"

fs       = require 'fs'
path     = require 'path'
crypto   = require 'crypto'

warn = (message) -> Fingerprint.logger.warn "fingerprint-brunch WARNING: #{message}"

unixify = (pathFile) -> pathFile.split('\\').join('/')

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
      # Remove old fingerprinted files
      autoClearOldFiles: false
      # Files you want to hash, default is all else put an array of files like ['app.js', 'vendor.js', ...]
      targets: '*'
      # Environment to make hash on files
      environments: ['production']
      # Force fingerprint-brunch to run in all environments when true.
      alwaysRun: false
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
      if @options.autoClearOldFiles
        # Search and destory old files if option is enable
        pattern = new RegExp(base + '\\-\\w+\\' + ext + '$');
        files = fs.readdirSync dir
        for oldFile in files
          filePath = path.normalize(dir + '/' + oldFile)
          if pattern.test oldFile then fs.unlinkSync filePath
      if @options.targets == '*' or (base + ext) in @options.targets
        newFileName = ''
        if (@config.env[0] not in @options.environments) and !@options.alwaysRun
          newFileName = file.path
        else
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
        keyPath = unixify(file.path)
        keyPath = keyPath.replace @options.srcBasePath, ""
        realPath = unixify(newFileName)
        realPath = realPath.replace @options.destBasePath, ""
        
        map[unixify(keyPath)] = unixify(realPath)
    
    # Merge array to keep not watched files
    if fs.existsSync @options.manifest
      manifest = fs.readFileSync @options.manifest, 'utf8'
      manifest = JSON.parse manifest
      manifest[k] = map[k] for k of map
      output = JSON.stringify manifest, null, "  "
    else
      output = JSON.stringify map, null, "  "
    
    fs.writeFileSync(@options.manifest, output)

Fingerprint.logger = console
module.exports = Fingerprint
