vm = require 'vm'

createNS = describe """
  """, (seedNS) ->
    seededNS = Object.assign {}, seedNS

