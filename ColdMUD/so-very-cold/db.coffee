# It's a function so we can pass in options later.

module.exports = ->
  class ObjectStore
    @comment: """
      I am (currently) an object <=> id bi-map.

        ::create(name: [parents]) - generates a new id and associates it with 'o'
        ::delete(o)               - removes the object and its id

        ::lookupId(id)            - returns the corresponding object
        ::idOf(o)                 - returns the id of 'o'

        ::allObjects()            - returns an iterator for all known objects
        ::allIds()                - returns

      I am constructed with injected delegates:
      
        store = new ObjectStore {CObject, CMethod}

        CObject:
          - parent/child relations
          - message -> method mapping/inheritance
          - instance data management

        CMethod:
          - Compiler
          - Callable object

      In the future I may also provide persistence of some sort.

    """

    constructor: (depends = {}) ->
      { @CObject
        @CMethod
      } = depends

      @_live = new Map
      @_byId = []

    create: (nameAndParents) ->
      for name, parents of nameAndParents
        @_live.set (o  = new @CObject parents),
                    id = (@_byId.push o) - 1
        o

    destroy: (o) ->
      try
        o.goingAway()

      if id = @_live.get o
        @_byId[id] = undefined
        @_live.delete o
        @

    lookupId: (id) -> @_byId[id]
    idOf:     (o)  -> @_live.get o

    allObjects: -> @_live.keys()
    allIds:     -> Object.keys @_byId

    [Symbol.iterator]: ->
      for object, id from @_live
        yield {id, object}

  class NamedObjectsStore extends ObjectStore
    @comment: """
      I add a [names] <=> object mapping to the ObjectStore class.

      Should this instead be implemeted
        - with a mixin?
        - with delegation?
        - as a decorator?
        - some other way?
    """

    constructor: (args...) ->
      super args...

      @objectToNames = new Map
      @namesToObjects = {}

    create: (args...) ->
      o = super args...
      @objectToNames[o] = new Set
      o

    destroy: (o) ->
      super o
      @delNames (@objectToNames[o])...
      @objectToNames.delete o

    lookupName: (name) -> @namesToObjects[name]

    addNames: (namesAndObjects) ->
      if (collisions = (name for name, object of namesAndObjects when @namesToObjects[name])).length
        throw new Error "name collisions: #{collisions}"

      for name, object of namesAndObjects
        @objectToNames[object].add name
        @namesToObjects[name] = object

      @

    delNames: (names...) ->
      for name in names when o = @namesToObjects[name]
        @objectToNames[o].delete name
        @namesToObjects[name] = undefined

      @

  {ObjectStore, NamedObjectStore}
