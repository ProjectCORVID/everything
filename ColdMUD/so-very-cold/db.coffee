# It's a function so we can pass in options later.

class ObjectStore
  @comment: """
    I am (currently) an object <=> id bi-map.

    ::add(o)    - generates a new id and associates it with 'o'
    ::delete(o) - removes the object and its id

    ::lookupId(n) - returns the corresponding object
    ::idOf(o)     - returns the id of 'o'

    ::allObjects() - returns an iterator for all known objects
    ::allIds()     - returns 
  """

  constructor: (@persister) ->
    @_live = new Map
    @_byId = []

  add: (o) ->
    unless id = @_live.get o
      id = (@_byId.push o) - 1
      @_live.set o, id
    id

  delete: (o) ->
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
    I add a [names] <=> object mapping to ObjectStore
  """
  constructor: (args...) ->
    super args...

    @objectToNames = new Map
    @namesToObjects = {}

  add: (o) ->
    @objectToNames[o] = new Set
    super o

  delete: (o) ->
    @delNames (@objectToNames[o] ? [])...
    super o

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

  lookup: (name) -> @namesToObjects[name]

class ColdDB extends NamedObjectsStore
  @comment: """
    Add ::init(dependencies)
  """

  init: ({CObject, CMethod}) ->
    DB = @

    method = (code) -> new CMethod code

    if sys  = (@lookup 'sys' ) and
       root = (@lookup 'root')
      return @

    [sys, root, cobject] = [0, 1].map -> new CObject
    @addNames {sys, root, cobject}

    sys.setParents [root]

    cobject.setHandlers
      ancestors: method (o) ->
        ancestors = []
        pending = o.

    root.setHandlers
      init: ->
        sys
          .ancestors @
          .filter (a) -> a.definesMethod 'init_child'
          .forEach (a) -> a.init_sending_child()

        @

      init_sending_child: ->
        #@setOn sender, names: new Set

      names:     -> DB.objectToNames[@]
      firstName: -> return name for name from @names()

      toString: ->
        "##{@id receiver}#{
          if name = await receiver.firstName() then " (#{name})" else ''
        }"


    #sys.setHandlers
    #  addNames: method (nameAndObject) ->
    #    assignments =
    #      for name, obj of nameAndObject
    #        if inUse = @objectsByName[name]
    #          if inUse isnt obj
    #            throw new Error "name '#{name}' already assigned to #{@id inUse}"
    #        else
    #          [name, obj]

    #    for [name, obj] in assignments.filter (o) -> o
    #      @objectsByName[name] = obj

    #    @

    #  rmNames: method (names...) ->
    #    @objectsByName[name] = undefined for name in [].concat names...

      starting: method -> console.log "starting event triggered"

    sys.call starting: []

module.exports = -> new ColdDB

