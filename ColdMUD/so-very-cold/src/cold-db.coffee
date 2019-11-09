export class ColdDB
  constructor: ({@CObject, @CMethod, @ObjectStore})->
    @db = new ObjectStore {@CObject}
    @propSym = Symbol 'ColdDB data'
    @names = {}

  create: (args...) ->
    o = @db.create args...
    (o[@propSym] = {}).names = new Set

    o

  destroy: (o) ->
    props = o?[@propSym]

    @db.destroy o

    if props
      @freeName name for name from props.names

    @

  allObjects: -> @db.allObjects()
  allIds:     -> @db.allIds()

  lookupId:   (id) -> @db.lookupId id
  idOf:       (o)  -> @db.idOf     o

  lookupName: (name) -> @names[name]
  namesOf:    (o)    -> copySet o[@propSym].names.values()

  freeName:   (name) ->
    try @names[name][@propSym].names.del name

    @names[name] ?= undefined

    return

  addNames: (nameAndObject) ->
    for name, obj of nameAndObject
      @freeName name
      @names[name] = obj
      obj[@propSym].names.add name

  init: ->
    method = (code) -> new CMethod code

    [@$sys, @$root, @$cobject] =
      [sys,   root,   cobject] =
      [  0,      1,         2]
        .map -> new CObject

    @addNames {sys, root, cobject}

    CObject.setParents sys,     [root]
    CObject.setParents cobject, [root]

    cobject.setHandlers
      parents:   method (o) -> CObject.parents o

      ancestors: method (o) ->
        [].concat ( await @parents o
                      .map (parent) ->
                        await @ancestors parent
                  )..., o
          .reduce (a, p) -> if p in a then a else a.concat p

      setParents: method (child, parents) ->
        CObject.setParents child, parents

    root.setHandlers
      init: (child) ->
        @setOn child, owner: null

      names:     -> @objectToNames[@]
      firstName: -> return name for name from @names()

      toString: ->
        "##{@id receiver}#{
          if name = await receiver.firstName() then " (#{name})" else ''
        }"

    sys.setHandlers
      starting: method -> console.log "starting event triggered"

    sys.call starting: []
