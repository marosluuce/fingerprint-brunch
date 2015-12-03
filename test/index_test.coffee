Fingerprint = require('../src/index')
expect      = require('chai').expect
fs          = require 'fs'
fse         = require 'fs-extra'
path        = require 'path'


Fingerprint.logger = {
  warn: (message) -> null # do nothing
}


ASSETS =
  'js/master.js': 'master-4fab3501.js'
  'css/master.css': 'master-f667f7a9.css'
  # 'troll.png': 'troll-uzevcec.png'
  # 'glyphicon.woff': 'glyphicon-uzevcec.woff'


fingerprintFilename = (filename) ->
  filename = ASSETS[filename] || filename
  path.join(__dirname, 'public', filename)

fingerprintFileExists = (filename) ->
  fs.existsSync(fingerprintFilename(filename))

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
      optimize: true
    )

  # executed after each test
  after ->
    fse.removeSync path.join(__dirname, 'public')

  describe 'general testing', ->
    # is instance of Plugin
    it 'is an instance of Fingerprint', ->
      expect(fingerprint).to.be.instanceOf(Fingerprint)

    # has default config
    it 'has default config keys', ->
      expect(fingerprint.options).to.include.keys('hashLength', 'environments')

  # Cleaning in dev env
  describe 'cleanning old hashed files', ->
    beforeEach ->
      # reset & copy assets to public
      setupFakeFileSystem()

    # check if exists
    it 'file to clean exists', ->
      expect(fingerprintFileExists('js/master-4fab3501.js')).to.be.true
    # cleanning files
    it 'cleanning file', ->
      fingerprint._clearOldFiles(path.join(__dirname, 'public', 'js'), 'master', '.js')
      expect(fingerprintFileExists('js/master-4fab3501.js')).to.be.false

  # renaming
    # rename css
    # rename js
    # rename fonts
    # rename img

  # manifest
  describe 'write manifest', ->
    # regular compile (as new one)
    # already exists

  # environment detection

  # inspecting
    # css
      # fonts => pattern font file
      # img => pattern image file
    # js
      # img pattern image file
