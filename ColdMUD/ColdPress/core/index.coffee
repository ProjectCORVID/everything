# This 'core' is more of a minimal-core initializer. It requires the
# underlying db to be new.

assert = require 'assert'
fs     = require 'fs'

# 'COP' is Cold Object Protocol
module.exports = (COP) ->
  $sys     = COP.create()
  $root    = COP.create()
  $cobject = COP.create()

  COP.setParents $sys,     [$root]
  COP.setParents $cobject, [$sys]

  (require 'sysAndRoot') COP
