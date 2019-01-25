newPrototype = null

module.exports =
  ColdDB: class ColdDB
    @comment: """
      Add ::init(dependencies)
    """

    @inject: ({NamedObjectStore}) ->
      newPrototype = Object.assign {}, NamedObjectStore::, @::
      :: = newPrototype
      Object.setPrototypeOf @, NamedObjectStore

    constructor: (args...) ->
      unless newPrototype
        throw new Error "Must inject NamedObjectStore dependency before use"

      super args...

    init: ->
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

        names:     -> @objectToNames[@]
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


