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
      # Image pattern format
      imagePatterns: ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'svg']
      # Image pattern format
      fontPatterns: ['woff', 'woff2', 'eot', 'ttf', 'otf', 'svg']
    }

    # FileData
    @filePath     = null
    @fileNewName  = null

    # Merge config
    cfg = @config.plugins?.fingerprint ? {}
    @options[k] = cfg[k] for k of cfg


  onCompile: (generatedFiles) ->
    map = {}
    # Open files
    for file in generatedFiles
      # Set var with generatedFile
      @filePath = file.path
      dir   = path.dirname(@filePath)
      ext   = path.extname(@filePath)
      base  = path.basename(@filePath, ext)

      # Search and destory old files if option is enable
      if @options.autoClearOldFiles
        @_clearOldFiles(dir, base, ext)

      if @options.targets == '*' or (base + ext) in @options.targets
        @fileNewName = @filePath
        if (@config.env[0] in @options.environments) or @options.alwaysRun
          @_renameFileToHash(dir, base, ext)

        # Unixify & Remove part from original path
        keyPath = unixify(@filePath)
        keyPath = keyPath.replace @options.srcBasePath, ""
        realPath = unixify(@fileNewName)
        realPath = realPath.replace @options.destBasePath, ""

        # Make array for manifest
        map[unixify(keyPath)] = unixify(realPath)

    # Merge array to keep not watched files
    if fs.existsSync @options.manifest
      @_mergeManifest(map)
    else
      @_whriteManifest(map)

  # Clear all old files
  # dir
  # base
  # ext
  _clearOldFiles: (dir, base, ext) ->
    # Find and remove file in dir/base-{hash}.ext
    pattern = new RegExp(base + '\\-\\w+\\' + ext + '$');
    files = fs.readdirSync dir
    for oldFile in files
      filePath = path.normalize(dir + '/' + oldFile)
      if pattern.test oldFile then fs.unlinkSync filePath

  # Generate hash with data of file
  # @filePath
  _generateHash: ->
    data = fs.readFileSync @filePath
    shasum = crypto.createHash 'sha1'
    shasum.update(data)
    return shasum.digest('hex')[0..@options.hashLength-1]

  # Make the hash
  # dir
  # base
  # ext
  _generateFileNameHashed: (dir, base, ext) ->
    hash = @_generateHash()
    newName = "#{base}-#{hash}#{ext}"
    return path.join(dir, newName)

  # @filePath
  _renameFileToHash: (dir, base, ext) ->
    fileNewName = @_generateFileNameHashed(dir, base, ext)
    # Rename file, with hash
    fs.renameSync(@filePath, fileNewName)


  # Manifest
  # map
  _whriteManifest: (map) ->
    output = JSON.stringify map, null, "  "
    fs.writeFileSync(@options.manifest, output)

  # map
  _mergeManifest: (map) ->
    manifest = fs.readFileSync @options.manifest, 'utf8'
    manifest = JSON.parse manifest
    manifest[k] = map[k] for k of map
    @_whriteManifest(manifest)

module.exports = Fingerprint
