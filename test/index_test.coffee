Fingerprint = require('../src/index')
expect      = require('chai').expect
fs          = require 'fs'
fse         = require 'fs-extra'
path        = require 'path'


Fingerprint.logger = {
  warn: (message) -> null # do nothing
}


ASSETS =
  'css/sample.css': 'css/sample-59b57315.css'
  'js/sample.js': 'js/sample-5d19fc29.js'

MAP =
  'public/css/sample.css': 'public/css/sample-59b57315.css'
  'public/js/sample.js': 'public/js/sample-5d19fc29.js'

GENERATED_FILES = [
  {path:path.join(__dirname, 'public', 'js', 'sample.js')},
  {path:path.join(__dirname, 'public', 'css', 'sample.css')}
]


fingerprintFilename = (filename) ->
  filename = ASSETS[filename] || filename
  path.join(__dirname, 'public', filename)

fingerprintFileExists = (filename) ->
  pathFile = fingerprintFilename(filename)
  fs.existsSync(pathFile)

setupFakeFileSystem = ->
  fse.removeSync path.join(__dirname, 'public')
  fse.copySync path.join(__dirname, 'fixtures'), path.join(__dirname, 'public')


describe 'Fingerprint', ->
  fingerprint = null

  # executed before each test
  beforeEach ->
    fingerprint = new Fingerprint(
      env: ['production']
      paths:
        public: path.join('test', 'public')
      plugins:
        fingerprint:
          manifest: './test/public/assets.json'
    )

  # executed after each test
  after ->
    fse.removeSync path.join(__dirname, 'public')

  describe 'General testing', ->
    it 'is an instance of Fingerprint', ->
      expect(fingerprint).to.be.instanceOf(Fingerprint)

    it 'has default config keys', ->
      expect(fingerprint.options).to.include.keys('hashLength', 'environments')

  # Cleaning in dev env
  describe 'Cleanning old hashed files', ->
    beforeEach ->
      setupFakeFileSystem()

    it 'is exists', ->
      pathFile = path.join(__dirname, 'public', 'js/sample.js')
      expect(fs.existsSync(pathFile)).to.be.true

    it 'is not exists', ->
      fingerprint._clearOldFiles(path.join(__dirname, 'public', 'js'), 'sample', '.js')
      expect(fingerprintFileExists('js/sample.js')).to.be.false

  # Renaming
  describe 'Renaming', ->
    beforeEach ->
      setupFakeFileSystem()

    it 'renames sample.css with fingerprint', ->
      fingerprint.options.alwaysRun = true
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('css/sample.css')).to.be.true

    it 'renames sample.js with fingerprint', ->
      fingerprint.options.alwaysRun = true
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('js/sample.js')).to.be.true

  # Manifest
  describe 'Write Manifest', ->
    beforeEach ->
      setupFakeFileSystem()

    it 'as new one', ->
      fingerprint._whriteManifest(MAP)
      exists = fs.existsSync(fingerprint.options.manifest)
      expect(exists).to.be.true

    it 'merging an already existing one', ->
      fingerprint._whriteManifest(MAP)
      fingerprint._mergeManifest(ASSETS)
      exists = fs.existsSync(fingerprint.options.manifest)
      expect(exists).to.be.true

  # Environment detection
  describe 'Environment detection', ->
    beforeEach ->
      setupFakeFileSystem()

    it 'does not run in non-production environment', ->
      fingerprint.config.env = []
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('js/sample.js')).to.be.false

    it 'does run with alwaysRun flag set', ->
      fingerprint.options.alwaysRun = true
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('js/sample.js')).to.be.true

    it 'does run in production environment', ->
      fingerprint.options.env = ['production']
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('js/sample.js')).to.be.true

  # Matching assets to hash
  describe 'Matching assets to hash', ->
    describe 'css files', ->
      # fonts => pattern font file
        # localiser le fichier css
        # localiser physiquement les fichiers sources concernés
          # app/assets => copié sans modification => écriture du fichier avec fsNode
          # app/fonts => copié via assetsmanager
        # renomer les fichiers physiquement
        # renomer les fichiers dans la css
      # img => pattern image file
    describe 'js files', ->
      # img pattern image file
