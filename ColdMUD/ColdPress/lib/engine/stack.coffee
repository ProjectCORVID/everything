module.exports = (COP) ->
  methodnf = (stack, target, method) ->
    stack.throw new MethodNotFound target, method, stack

  class Stack
    constructor: ->
      @frames = []

    call: (target, method, args) ->
      call = {target, method, args}

      unless call.handler = target.findMethod method
        methodnf @, target, method
        return

      @frames.push frame = new Stack.Frame @, call
      frame.start()

    throw: (error) ->

  class Stack.Frame
    constructor: (@stack, @call) ->

    start: ->
      @call.handler @

