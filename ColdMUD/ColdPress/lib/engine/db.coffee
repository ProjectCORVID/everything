class ColdDB
  @comment: '''
    I encapsulate persistence of ColdPress objects. My children implement
    fancy features like caching. Whee.
  '''

  constructor: ->
    @objects = []
    @dbTop   = 0

  get: (id) ->
    @objects[id]

  commit: (o) ->
    @objects[o.id] = o

  create: ->
    Objects.assign (
        @objects[id = @dbTop++] =
          new ColdObjectHandle @
      ), {id}


