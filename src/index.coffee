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
      # autoReplaceAndHash assets in css/js
      autoReplaceAndHash: true
      # Image pattern format
      imagePatterns: new RegExp(/url\([\'\"]?[a-zA-Z0-9\-\/_.:]+\.(woff|woff2|eot|ttf|otf|jpg|jpeg|png|bmp|gif|svg)\??\#?[a-zA-Z0-9\-\/_]*[\'\"]?\)/g)
    }
    # Merge config
    cfg = @config.plugins?.fingerprint ? {}
    @options[k] = cfg[k] for k of cfg

  onCompile: (generatedFiles) ->
    map          = {}

    # Open files
    for file in generatedFiles
      # Set var with generatedFile
      filePath = file.path
      dir   = path.dirname(filePath)
      ext   = path.extname(filePath)
      base  = path.basename(filePath, ext)
      # Search and destory old files if option is enable
      if @options.autoClearOldFiles
        @_clearOldFiles(dir, base, ext)
      if @options.targets == '*' or (base + ext) in @options.targets
        fileNewName = filePath
        if @options.autoReplaceAndHash and fs.existsSync(filePath)
          @_autoReplaceAndHash(filePath)
        else if (@config.env[0] in @options.environments) or @options.alwaysRun
          fileNewName = @_renameFileToHash(filePath)
        # Unixify & Remove part from original path
        keyPath = unixify(filePath)
        keyPath = keyPath.replace @options.srcBasePath, ""
        realPath = unixify(fileNewName)
        realPath = realPath.replace @options.destBasePath, ""
        # Make array for manifest
        map[unixify(keyPath)] = unixify(realPath)
    # Merge array to keep not watched files
    if fs.existsSync @options.manifest
      @_mergeManifest(map)
    else
      @_whriteManifest(map)

  # _autoReplaceAndHash
  _autoReplaceAndHash: (filePath) ->
    # read file and match url(**)
    config = @config
    options = @options
    that = this

    contents = fs.readFileSync(filePath).toString()
    paths = contents.match(@options.imagePatterns)
    if paths != null
      Object.keys(paths).forEach (key) ->
        # get path
        match = paths[key]
        paths[key] = paths[key].substring(paths[key].lastIndexOf("(")+1,paths[key].lastIndexOf(")")).replace(/\"/g,'').replace(/\'/g,"").replace(/\#[a-zA-Z0-9\-\/_]*/g,"").replace(/\?[a-zA-Z0-9\-\/\#_]*/g,"")
        # target exists ?
        targetPath = path.join(config.paths.public, paths[key])
        if fs.existsSync(targetPath)
          # rename file
          targetNewName = that._renameFileToHash(targetPath)
          match = new RegExp(match.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"), 'g')
          # rename path in css
          contents = contents.replace(match, "url('" + unixify(targetNewName.substring(targetNewName.lastIndexOf("public")+6)) + "')")

      if (config.env[0] in options.environments) or options.alwaysRun
        filePath = that._generateFileNameHashed(filePath, contents)

      # write file to generate
      fs.writeFileSync(filePath, contents, 'utf8')

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
  # filePath
  _generateHash: (data) ->
    shasum = crypto.createHash 'sha1'
    shasum.update(data.toString('utf8'), 'utf8')
    return shasum.digest('hex')[0..@options.hashLength-1]

  # Make the hash
  # dir
  # base
  # ext
  _generateFileNameHashed: (filePath) ->
    hash = null
    if (arguments[1])
      hash = @_generateHash(arguments[1])
    else
      data = fs.readFileSync filePath
      hash = @_generateHash(data)

    dir   = path.dirname(filePath)
    ext   = path.extname(filePath)
    base  = path.basename(filePath, ext)
    newName = "#{base}-#{hash}#{ext}"
    return path.join(dir, newName)

  _renameFileToHash: (filePath) ->
    fileNewName = @_generateFileNameHashed(filePath)
    # Rename file, with hash
    fs.renameSync(filePath, fileNewName)
    fileNewName

  _writeFileToHash: (filePath) ->
    fileNewName = @_generateFileNameHashed(filePath)
    # Rename file, with hash
    fileNewName

  # Manifest
  _removeManifest: ->
    fs.unlinkSync @options.manifest

  _whriteManifest: (map) ->
    output = JSON.stringify map, null, "  "
    fs.writeFileSync(@options.manifest, output)

  _mergeManifest: (map) ->
    manifest = fs.readFileSync @options.manifest, 'utf8'
    manifest = JSON.parse manifest
    manifest[k] = map[k] for k of map
    @_whriteManifest(manifest)

module.exports = Fingerprint