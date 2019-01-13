{ Persisted, TimeTraveler } = require './persistence'
CoffeeScript = require 'coffee-script'

class Funtionality extends TimeTraveler
  @thaw: (frozen) ->
    thawed = new Functionality

    for name, source of frozen
      thawed.updateMethod name, source

    return thawed

  constructor: ->
    super
    @_source = {}

  chilled: ->
    # Need something like .filter for maps...

    @_source = Object.assign {},
      ("#{k}": v for k, v of @_source when v)...

    JSON.stringify @_source

  updateMethod: (name, source) ->
    fn = CoffeeScript.eval source
    @_source[name] = source
    @[name] = fn

  deleteMethod: (name) ->
    @[name] = @_source[name] = undefined

