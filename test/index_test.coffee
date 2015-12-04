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
  'img/troll.png': 'img/troll-uzevcec.png'
  # 'glyphicon.woff': 'glyphicon-uzevcec.woff'

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
    )

  # executed after each test
  after ->
    fse.removeSync path.join(__dirname, 'public')

  describe 'General testing', ->
    # is instance of Plugin
    it 'is an instance of Fingerprint', ->
      expect(fingerprint).to.be.instanceOf(Fingerprint)

    # has default config
    it 'has default config keys', ->
      expect(fingerprint.options).to.include.keys('hashLength', 'environments')

  # Cleaning in dev env
  describe 'Cleanning old hashed files', ->
    beforeEach ->
      # reset & copy assets to public
      setupFakeFileSystem()

    # check if exists
    it 'is exists', ->
      pathFile = path.join(__dirname, 'public', 'js/sample.js')
      expect(fs.existsSync(pathFile)).to.be.true

    # cleanning files
    it 'is not exists', ->
      fingerprint._clearOldFiles(path.join(__dirname, 'public', 'js'), 'sample', '.js')
      expect(fingerprintFileExists('js/sample.js')).to.be.false

  # Renaming
  describe 'Renaming', ->
    beforeEach ->
      # reset & copy assets to public
      setupFakeFileSystem()

    # rename css
    it 'renames sample.css with fingerprint', ->
      fingerprint.options.alwaysRun = true
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('css/sample.css')).to.be.true
    # rename js
    it 'renames sample.js with fingerprint', ->
      fingerprint.options.alwaysRun = true
      fingerprint.onCompile(GENERATED_FILES)
      expect(fingerprintFileExists('js/sample.js')).to.be.true

  # Manifest
  describe 'Manifest', ->
    # regular compile (as new one)
    describe 'Write manifest', ->

    # already exists
    describe 'Merging manifest', ->


  # environment detection
  describe 'Environment detection', ->
    beforeEach ->
      # reset & copy assets to public
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

  # inspecting
    # css
      # fonts => pattern font file
      # img => pattern image file
    # js
      # img pattern image file
