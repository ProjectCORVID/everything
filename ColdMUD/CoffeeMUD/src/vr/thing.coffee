module.exports =
class Thing extends $sys.root
  constructor: ->
    super arguments...
    @_contents = []
    @_location = null
    @_description = ''

  description: ->
    @_description or @defaultDescription?() or "You see nothing special."

  addThing: (thing) ->
    if thing not in @_contents
      @_contents.push thing

  removeThing: (thing) ->
    @_contents =
      @_contents
        .filter (item) -> item isnt thing

  moveTo: (dst) ->
    try
      @_location?.removeThing? @

    @_location = null
    dst.addThing @
    @_location = dst
