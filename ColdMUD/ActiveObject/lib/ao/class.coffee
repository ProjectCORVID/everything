EventEmitter = require 'events'

module.exports = (AO, debug) ->
  class AO::AModel extends EventEmitter
    @comment: """
        My children represent the structure and behavior of an AO model.
      """

    constructor: (@parent = null) ->
      @symbol = Symbol()
      @schema = new AO::ASchema

    create: ->
      # Creates an instance of the model
      return

    addProp: (name, defaultValue) ->
      @schema.addProp name, defaultValue
