class Persisted
  constructor: (@these) ->
    @db = db.add @

  storeTo: ({@db, @id}) ->

  freeze: ->
    frozen =
      klass: @constructor
      id:    @id
      aspects: {}

    for name, aspect in @_aspects()
      frozen.aspects[name] = aspect.freeze()

  thaw: (frozen) ->
    throw new Error "#{@constructor.name} and its parents do not implement the ::thaw virtual method."

  _aspects: ->

module.exports = { Persisted }
