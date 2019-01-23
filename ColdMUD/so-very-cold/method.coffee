vm           = require 'vm'
coffeescript = require 'coffeescript'
CSNodes      = require 'coffeescript/lib/coffeescript/nodes'

module.exports = ({CObject}) ->
  class CMethod
    constructor: (@source) ->
    call: ({sender, caller, receiver, definer}, args...) ->

  {CMethod}
