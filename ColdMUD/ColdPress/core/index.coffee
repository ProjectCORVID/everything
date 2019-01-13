# This 'core' is more of a minimal-core initializer. It requires the
# underlying db to be new.

assert = require 'assert'
fs     = require 'fs'

# 'COP' is Cold Object Protocol
module.exports = (COP) ->
  $sys  = COP.create()
  $root = COP.create()

  asser.equal  $sys.id, 0, "First object must have id 0, not #{sys.id}"
  asser.equal $root.id, 1, "Second object must have id 1, not #{root.id}"

  COP.setParents $sys, [$root]

  (require 'sysAndRoot') COP
