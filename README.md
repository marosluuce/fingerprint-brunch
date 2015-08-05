fingerprint-brunch
=============

A [Brunch][] plugin witch rename assets with a SHA for fingerprinted it.

Installation
-------

`npm install fingerprint-brunch --save-dev`


Options
-------
_Optional_ You can override fingerprint-brunch's default options by updating your `brunch-config.coffee` with overrides.

Default settings:

```coffeescript
exports.config =
  # ...
  plugins:
    fingerprint:
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
```

License
-------

MIT

[Brunch]: http://brunch.io
