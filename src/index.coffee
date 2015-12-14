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
      alwaysRun: true
      # autoReplaceAndHash assets in css/js
      autoReplaceAndHash: true
      # Image pattern format
      # authorized chars : ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=
      imagePatterns: new RegExp(/url\([\'\"]?[a-zA-Z0-9\-\/_.:]+\.(woff|woff2|eot|ttf|otf|jpg|jpeg|png|bmp|gif|svg)\??\#?[a-zA-Z0-9\-\/_]*[\'\"]?\)/g)
    }
    # Map of assets
    @map = {}

    # Merge config
    cfg = @config.plugins?.fingerprint ? {}
    @options[k] = cfg[k] for k of cfg

  # Main method
  onCompile: (generatedFiles) ->
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

      # Hash only file in targets option key
      if @options.targets == '*' or (base + ext) in @options.targets
        if @options.autoReplaceAndHash and fs.existsSync(filePath)
          # Fingerprint sub files
          @_findAndReplaceSubAssets(filePath)
        else
          @_makeCoffee(filePath)

    # Make array for manifest
    if fs.existsSync @options.manifest
      # Merge array to keep not watched files
      @_mergeManifest()
    else
      @_writeManifest()

  _makeCoffee: (filePath) ->
    fileNewName = filePath
    if @_isFingerprintable()
      # Just fingerprint targets
      fileNewName = @_fingerprintFile(filePath)
    @_addToMap(filePath, fileNewName)

  # Unixify & Remove part from original path
  _addToMap: (fileInput, fileOutput) ->
    fileInput = @_removePathBeforePublic(fileInput)
    fileOutput = @_removePathBeforePublic(fileOutput)

    # Remove srcBasePath/destBasePath
    fileInput = fileInput.replace @options.srcBasePath, ""
    fileOutput = fileOutput.replace @options.destBasePath, ""

    # Adding to @map var
    @map[fileInput] = fileOutput

  # Remove path before the public
  _removePathBeforePublic: (path) ->
    path = unixify path
    pathPublicIndex = path.indexOf(unixify(@config.paths.public))
    if (pathPublicIndex != 0)
      path = path.substring(pathPublicIndex)
    return path

  # Find dependencied like image, fonts.. Hash them and rewrite files (CSS only for now)
  _findAndReplaceSubAssets: (filePath) ->
    # read file and match url(**)
    config = @config
    options = @options
    that = this

    contents = fs.readFileSync(filePath).toString()
    paths = contents.match(@options.imagePatterns)
    if paths != null
      # find file into generatedFiles
      Object.keys(paths).forEach (key) ->
        # get path
        match = paths[key]
        paths[key] = paths[key].substring(paths[key].lastIndexOf("(")+1,paths[key].lastIndexOf(")")).replace(/\"/g,'').replace(/\'/g,"")
        finalHash = ''
        param = paths[key].match(/(\?|\#)[a-zA-Z0-9\-\/\#_]*/g)
        if param != null
          Object.keys(param).map (key) ->
            finalHash += param[key]
        paths[key] = paths[key].replace(/(\?|\#)[a-zA-Z0-9\-\/\#_]*/g, '')
        # target exists ?
        targetPath = unixify(path.join(config.paths.public, paths[key]))
        if fs.existsSync(that.map[targetPath] || targetPath)
          if typeof(that.map[targetPath]) == 'undefined'
            # rename file
            targetNewName = that._fingerprintFile(targetPath)
            that._addToMap(targetPath, path.join(config.paths.public, targetNewName.substring(config.paths.public.length)))
          else
            targetNewName = that.map[targetPath]
          match = new RegExp(match.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"), 'g')
          # add to map
          # rename path in css
          contents = contents.replace(match, "url('" + unixify(targetNewName.substring(config.paths.public.length)) + finalHash + "')")
      # END find file into generatedFiles

      modifiedFilePath = filePath
      if @_isFingerprintable()
        modifiedFilePath = @_fingerprintCompose(filePath, contents)

      # write file to generate
      fs.writeFileSync(modifiedFilePath, contents, 'utf8')
      @_addToMap(filePath, modifiedFilePath)
    else
      @_makeCoffee(filePath)

  # IsFingerprintable
  _isFingerprintable: ->
    return (@config.env[0] in @options.environments) or @options.alwaysRun

  # Clear all the fingerprinted files
  _clearOldFiles: (dir, base, ext) ->
    # Find and remove file in dir/base-{hash}.ext
    pattern = new RegExp(base + '\\-\\w+\\' + ext + '$');
    files = fs.readdirSync dir
    for oldFile in files
      filePath = path.normalize(dir + '/' + oldFile)
      if pattern.test oldFile then fs.unlinkSync filePath

  # Make hash from data of file
  _makeFingerprintWithData: (data) ->
    shasum = crypto.createHash 'sha1'
    shasum.update(data.toString('utf8'), 'utf8')
    return shasum.digest('hex')[0..@options.hashLength-1]

  # Compose file name
  _fingerprintCompose: (filePath) ->
    hash = null
    if (arguments[1])
      hash = @_makeFingerprintWithData(arguments[1])
    else
      data = fs.readFileSync filePath
      hash = @_makeFingerprintWithData(data)

    dir   = path.dirname(filePath)
    ext   = path.extname(filePath)
    base  = path.basename(filePath, ext)
    newName = "#{base}-#{hash}#{ext}"
    return path.join(dir, newName)

  # Rename file with his new fingerprint
  _fingerprintFile: (filePath) ->
    fileNewName = @_fingerprintCompose(filePath)
    # Rename file, with hash
    fs.renameSync(filePath, fileNewName)
    fileNewName

  # Remove existing manifest
  _removeManifest: ->
    if fs.existsSync(@options.manifest) then fs.unlinkSync @options.manifest

  # Write a new manifest
  _writeManifest: ->
    output = JSON.stringify @map, null, "  "
    fs.writeFileSync(@options.manifest, output)

  # Merging existing manifest with new entree
  _mergeManifest: ->
    manifest = fs.readFileSync @options.manifest, 'utf8'
    manifest = JSON.parse manifest
    manifest[k] = @map[k] for k of @map
    @_writeManifest(manifest)

module.exports = Fingerprint