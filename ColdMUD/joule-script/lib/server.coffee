class Server
  constructor: (nameAndDef) ->
    if 'object' isnt typeof nameAndDef or
        ([name] = Object.getOwnPropertyNames nameAndDef).length isnt 1
      throw new Error 'expected single-key object'

    def = nameAndDef[name]
    @facets = []

  o: (bindingName, message) ->
    @bindings[bindingName] message
