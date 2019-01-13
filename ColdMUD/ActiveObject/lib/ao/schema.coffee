module.exports = (AO, debug) ->
  { EventEmitter } = require 'events'

  class AO::Schema extends EventEmitter
    @comment: """
        My children represent the internal structure of instances of an AModel.
      """

    constructor: (@definingModel) ->
      @symbol = Symbol()
      @propDefs = {}
