Fingerprint   = require('../src/index')
expect    = require('chai').expect
fs        = require 'fs'
path      = require 'path'

Fingerprint.logger = {
  warn: (message) -> null # do nothing
}

ASSETS = 
  'master.js': 'master-uzevcec.js'
  'master.css': 'master-uzevcec.css'
  'troll.png': 'troll-uzevcec.png'
  'glyphicon.woff': 'glyphicon-uzevcec.woff'



fingerprintFilename = (filename) ->
  path.join(__dirname, 'public', filename)

fingerprintFileExists = (filename) ->
  fs.existsSync(fingerprintFilename(filename))

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

  # is instance of Plugin
  it 'is an instance of Fingerprint', ->
    expect(fingerprint).to.be.instanceOf(Fingerprint)

  # has default config
  it 'has default config keys', ->
    expect(fingerprint.options).to.include.keys('precision', 'referenceFiles')

  # Cleaning in dev env
  describe 'cleanning old hashed files', ->
    beforeEach ->
      # build assets
      fingerprint.onCompile()

    it 'cleanning old generated files', ->
      # cleanning files
      expect(digestFileExists('js/nested.js')).to.be.true
      # check if exists
      expect(digestFileExists('js/nested.js')).to.be.true
      expect(digestFileExists('js/nested.js')).to.be.true

  # renaming
    # rename css
    # rename js
    # rename fonts
    # rename img

  # manifest
    # regular compile (as new one)
    # already exists

  # environment detection

  # inspecting
    # css
      # fonts => pattern font file
      # img => pattern image file
    # js
      # img pattern image file
