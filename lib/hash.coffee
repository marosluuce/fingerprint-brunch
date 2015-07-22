crypto = require 'crypto'

module.exports = (source, encoding) ->

  md5sum = crypto.createHash 'md5'

  md5sum.update source, encoding

  return md5sum.digest 'hex'
