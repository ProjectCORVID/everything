# It's a function so we can pass in options later.

module.exports = ->
  Object.assign DB = [],
    init: ({CObject, CMethod}) ->
      method = (code) -> new CMethod code

      $sys  = new CObject
      $root = new CObject

      $sys.setParents [$root]

      $root.set $root, 'names'

      $root.setHandlers
        init: ->
          $sys
            .ancestors @
            .filter (a) -> a.definesMethod 'init_child'
            .forEach (a) -> a.init_sending_child()

          @

        init_sending_child: ->
          @setOn sender, names: new Set

        names:     ->        name for name from (@get 'names') ? []
        firstName: -> return name for name from (@get 'names') ? []

        toString: ->
          "##{@id receiver}#{
            if name = await receiver.firstName() then " (#{name})" else ''
          }"


      $sys.setHandlers
        addNames: method (nameAndObject) ->
          assignments =
            for name, obj of nameAndObject
              if inUse = @objectsByName[name]
                if inUse isnt obj
                  throw new Error "name '#{name}' already assigned to #{@id inUse}"
              else
                [name, obj]

          for [name, obj] in assignments.filter (o) -> o
            @objectsByName[name] = obj

          @

        rmNames: method (names...) ->
          @objectsByName[name] = undefined for name in [].concat names...

        starting: method -> console.log "starting event triggered"

      $sys.call init: []

      $sys.call
        addNames:
          root: $root
          sys:  $sys

      $sys.call starting: []
