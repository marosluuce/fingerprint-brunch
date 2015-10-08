fingerprint-brunch
=============

A [Brunch][] plugin witch rename assets with a SHA for fingerprinted it.

[![NPM](https://nodei.co/npm/fingerprint-brunch.png)](https://nodei.co/npm/fingerprint-brunch/)
[![NPM](https://nodei.co/npm-dl/fingerprint-brunch.png?months=3)](https://nodei.co/npm/fingerprint-brunch/)

Installation
-------

`npm install fingerprint-brunch --save-dev`


Configuration
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
      # Environment to make hash on files
      environments: ['production']
      # Force fingerprint-brunch to run in all environments when true.
      alwaysRun: false
```


Usage
-------
The manifest generated seem to this.
```json
{
  "css/master.css": "css/master-364b42a1.css",
  "js/master.js": "js/master-cb60c02b.js"
}
```

With `srcBasePath` and `destBasePath` you can remove some part of your path files.

Like if `srcBasePath` equal to '../../public/theme/', `../../public/theme/css/master.css` begin `css/master.css`.

In your code your can make a little script to read this `assets.json` and next get the real path with the key `js/master.js`.

If your have any questions or suggestions, ask me !


To Do
-------
- Add a rewriter/replacer of file path in css (for images, fonts..)


License
-------

MIT

[Brunch]: http://brunch.io
