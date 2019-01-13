module.exports = (COP) ->
  class ColdObjectHandle
    @comment: '''
      I am the internal interface to a ColdPress object. My current
      implementation makes no distinction between a handle and the object
      itself. A future version will decouple these concepts.
    '''

    constructor: (@id) ->
      @id      = COP.id @

      @parents = []
      @data    = []

      @props   = {}
      @methods = {}

    # o.defineProps foo: fooInfo, bar, baz: bazInfo
    defineProps: (args...) ->
      @defineProps namesAndDefaults for namesAndDefaults in args

      return

    defineProp: (namesAndDefaults) ->
      if 'object' is typeof namesAndDefaults
        for name, def of nameAndDefault
          if Array.isArray def
            [def, value] = def
          else
            value = def
          @_defineProp name, {default: def, value}

      return

    _defineProp:    (name, def) -> @props[name] = def

    propDefault:    (name) -> @props[name].default

    propDefinition: (definer, name) -> COP.getPropDefinition definer, name

    propIsSet:      (definer, name) ->
      if not definerData = @propDef definer, name
        throw new Error '~propnf'

      definerData[name] isnt undefined
    propValue:      (definer, name) ->
      if not definerData = @propDef definer, name
        throw new Error '~propnf'

      if definerData[name] is undefined
        definer.propDefault name

    findMethod: (name) ->
      if impl = @methods[name]
        {name, definer: @, impl}
      else
        @_findMethodInParents name

    _findMethodInParents: (name) ->
      for parent in @parents
        if found = parent.findMethod name
          return found

      undefined

    setMethod: (nameAndDef) ->
      for name, def of nameAndDef
        @_setMethod name, def

    _setMethod: (name, def) ->
      if m = @findMethod name and m.definer isnt @id
        if m.disallow_overrides
          throw eperm

      @methods[name] = def

