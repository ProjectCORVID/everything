class Facet
  constructor: (@server, @handler) ->

  receive: (message) ->
    @server[@handler] message

