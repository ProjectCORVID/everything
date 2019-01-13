path   = require 'path'

{load} = require './load'

core   = global # obviate {$sys} = require /(../)+core/ in sub-modules

loadSection = (name) ->
  fsPath = path.resolve __dirname, name
  load fsPath, '$' + name, core

'sys vr world'
  .split ' '
  .map loadSection

$sys.startup()
