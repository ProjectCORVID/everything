{join, basename, relative, resolve} =
path = require 'path'
fs   = require 'fs'

comment = """
  
  I implement a namespace feature mapping directories and files to objects.
  
  Usage:
 
    lib    = (require 'ns') 'path/to/lib'
    engine = lib.engine         # like require 'lib/engine'
    client = lib.client.console # like require 'lib/client/console'

  (found in #{join __dirname, basename __filename, '.coffee'})
"""

isDir = (f) ->
  fs.statSync f
    .isDirectory()

proxyPath = (pathStr, parent) ->
  rel = relative pathStr, __dirname

  if '..' in rel
    throw new Error 'Not allowed to escape ' + __dirname

  return _proxyPath (rel or __dirname)

_proxyPath = (rel) ->
  p = {}

  for entry in fs.readdirSync rel
    if isDir entryPath = resolve rel, entry
      try
        p[entry] = require entryPath
      catch e
        p[entry] = _proxyPath entryPath

      continue

    for ext in require.extensions
      if entry.endsWith ext
        basename = basename entry, ext
        p[basename] = require entryPath
        break

  p

module.exports = proxyPath __dirname

global.comment = (str, o) ->
  if o['comment']
    str = [o.comment, str].join '\n'

  Object.assign o, comment: str
