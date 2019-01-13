COLD_GLOBAL_OBJECT_PROXY =
  comment 'I define the handlers for global ColdPress object proxies.',
    apply:                    -> throw new Error "Global objects are not functions"
    construct:                -> throw new Error "Use the ColdObjectProtocol to construct children of Cold objects"

    defineProperty:           -> throw new Error "Global objects are externally immutable"
    deleteProperty:           -> throw new Error "Global objects are externally immutable"
    set:                      -> throw new Error "Global objects are externally immutable"

    getOwnPropertyDescriptor: -> throw new Error "Use the ColdObjectProtocol to inspect children of Cold objects"
    getPrototypeOf:           -> throw new Error "Use the ColdObjectProtocol to inspect children of Cold objects"
    has:                      -> throw new Error "Use the ColdObjectProtocol to inspect children of Cold objects"
    setPrototypeOf:           -> throw new Error "Use the ColdObjectProtocol to inspect children of Cold objects"

    preventExtensions:        -> true # should never come up in practice, but whatever
    isExtensible:             -> false
    ownKeys:                  -> []

    get: (instance, name, proxy) -> instance.findMethod name

module.exports = (COP) ->
  COP.createProxy =
    comment 'I create proxies to ColdPress objects exposed to ColdMethods.',
      (instance) ->
        unless instance instanceOf COP.engine.object.handle
          throw new Error "createProxy called with invalid non-handle argument"

        if proxy = COP.getProxy instance
          return proxy

        proxy = new Proxy instance, COLD_GLOBAL_OBJECT_PROXY
        COP.registerProxy instance, proxy
