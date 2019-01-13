module.exports =
class Root
  constructor: (info = {}) ->
    { @name        = null
      @namespace   = @name and $sys.namespace.resolve @coldParent.namespace, @name
    } = info

    @namespace?.register @name, @
