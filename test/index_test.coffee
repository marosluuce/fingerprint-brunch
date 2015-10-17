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

  it 'optimize', ->
    css = fs.readFileSync('test/fixtures/sample.css', 'utf-8')
    expected = fs.readFileSync('test/fixtures/sample.out.css', 'utf-8')
    fingerprint.optimize {data: css}, (err, data) ->
      expect(data.data).to.be.eql(expected)

  it 'optimize with sourcemaps', ->
    css = fs.readFileSync('test/fixtures/sample.css', 'utf-8')
    map = {
      version: 3
      sources: [ 'sample.css' ]
      names: []
      mappings: 'AAAA,iBAQC,AARD,UACI,iBAA4B,AAC5B,UAAe,AAEf,mBAAoB,AAEpB,gBAAoB,AACpB,qBAAuB,CAC1B'
      file: 'sample.css'
    }
    fingerprint.optimize {data: css, path: 'test/fixtures/sample.css'}, (err, data) ->
      expect(data.map).to.be.eql(map)
