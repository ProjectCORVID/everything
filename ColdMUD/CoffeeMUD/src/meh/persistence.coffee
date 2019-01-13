{ needs, combines } = require './aspect'

class ObjStore
  fetch: (key) ->
    throw new Error "virtual method not implemented"

  create: (persisted) ->
    throw new Error "virtual method not implemented"

class InMemoryDB extends ObjStore
  constructor: ->
    @nextId = 0
    @store  = []

  update: (o) ->
    @store[o.id] = o.freeze()

  create: (o) ->
    o.asPersisted.storeTo db: @, id: @nextId++
    @update o.asPersisted

  fetch: (id)  ->
    (frozen = @store[id])
      .klass.thaw frozen

module.exports = { InMemoryDB }

