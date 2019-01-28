comment = """
"""

# TODO: Can we refactor out the object store? Maybe move create/destroy to the
# store and provide CObject to the store as a dependency?

DB = null

resolveObject = (idOrObject) ->
  if   o = DB.lookupId id = idOrObject or
      id = DB.idOf      o = idOrObject
    return {o, id}

  # throw new Error "Could not resolve object with reference provided (#{idOrObject})"

  #if o.id isnt id
  #  throw new Error "Object store integrity error: ##{id}.id is #{o.id}, expected #{id}"

obj = (id) -> resolveObject(id)?.o
id  = (o)  -> resolveObject(o )?.id


objArgs = -> (objs) ->
  [].concat objs...
    .map id

module.exports = { CObject }
  class CObject
    @inject: ({objectStore}) ->
      if DB then throw new Error "Cannot re-inject"

      (DB = objectStore)
        .init()

    constructor: (parentIds = []) ->
      @id        = DB.add @

      @_parents  = new Set
      @_children = new Set

      @_data     = {}
      @_handlers = {}

    goingAway: ->
      for c from @_children
        c.delParents @
        c.addParents p for p from @_parents

      for p from @_parents
        p.children.delete @

      return

    parents:  -> @_parents .values()
    children: -> @_children.values()

    addParents: (parentLists...) ->
      for p in objArgs parentLists when not @_parents.has p
        @_parents .add p
        p.children.add @

        @_data[p] = {}
      return

    delParents: (parentLists...) ->
      for p in objArgs parentLists when     @_parents.has p
        @_parents .delete p
        p.children.delete @

        @_data[p] = undefined
      return

    setParents: (newParents, moreParents...) ->
      @delParents p for p from  @_parents when p not in newParents
      @addParents p for p from newParents when p not in  @_parents
      return

    get: (definer, name)        -> @_data[id definer][name]
    set: (definer, name, value) -> @_data[id definer][name] = value

    delHandlers: (names...)       -> @_handlers[name] = undefined for name          in names
    setHandlers: (nameAndHandler) -> @_handlers[name] = handler   for name, handler of namesAndHandlers

    findHandler: (name) ->
      if method = @_handlers[name]
        return definer: @id, handler: method

      for parent in @_parents.map obj
        if found = parent.findHandler name
          return found

      return

    toString: ->
      "##{@_id}#{
        if (names = @_data[1]?.names)?.length
          " (#{names[0]})"
        else
          ""
      }"

    send: (source, message, args) ->
      unless found = @findHandler message
        throw new Error "handler for #{message} not found on #{@toString()}"

      sender = source.receiver
      caller = source.definer

      found.call Object.assign {sender, caller, receiver, definer, message, args}

  return Object.assign CObject, {obj, id}, forTesting: {resolveObject}

Object.assign module.exports, {comment}

