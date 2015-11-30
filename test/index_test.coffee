Fingerprint   = require('../src/index')
expect    = require('chai').expect
fs        = require 'fs'
path      = require 'path'

Fingerprint.logger = {
  warn: (message) -> null # do nothing
}

describe 'Fingerprint', ->

  fingerprint = null

  beforeEach ->
    fingerprint = new Fingerprint(
      env: ['production']
      paths:
        public: path.join('test', 'public')
      optimize: true
    )

  it 'is an instance of Fingerprint', ->
    expect(fingerprint).to.be.instanceOf(Fingerprint)

  # has default config

  # cleanning oldFiles

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
