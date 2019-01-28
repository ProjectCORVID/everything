export class ObjectStore
  @comment: """
    I am (currently) an object <=> id bi-map.

      ::create(name: [parents]) - generates a new id and associates it with 'o'
      ::delete(o)               - removes the object and its id

      ::lookupId(id)            - returns the corresponding object
      ::idOf(o)                 - returns the id of 'o'

      ::allObjects()            - returns an iterator for all known objects
      ::allIds()                - returns

    I am constructed with injected delegates:
    
      store = new ObjectStore {CObject}

      CObject:
        - parent/child relations
        - message -> method mapping/inheritance
        - instance data management

  """

  constructor: (depends = {}) ->
    { @CObject
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
