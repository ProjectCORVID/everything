## ColdStack


    class ColdStackFrame
      constructor: (@prev, info) ->
        { @receiver, @definer
          @method, @args
        } = info
        @return = undefined

    Object.defineProperties ColdStackFrame::,
      sender: get: -> if @prev then @prev.reciver
      caller: get: -> if @prev then @prev.caller

    class ColdStack
      constructor: ->
        @frames = []
