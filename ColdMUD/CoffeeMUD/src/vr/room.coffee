module.exports =
class room extends $vr.thing
  constructor: ->
    super arguments...
    @_exits = []

  digToExisting: (name, dst) ->
    @_exits.push $vr.Exit.create {name, src: @, dst}

  digToNew: (name, dstName) ->
    dst = $vr.Room.create {name: dstName}

  description: ->
    super() + '\n' + @exitsDescription()

  exitsDescription: ->
    switch (exits = @exits()).length
      when 0 then "There are no visible exits."
      when 1 then "There is an exit #{exits[0].nameForRoomDescription()}."
      else        "There are exits " +
                    $vr.english.listToString exits.map $sys.util.createCall methodName: 'nameForRoomDescription'

  attempt: (actor, action) ->
    # broadcast the attempt
    # gather the repercussions
    # commit the results to the log
    # broadcast the results
