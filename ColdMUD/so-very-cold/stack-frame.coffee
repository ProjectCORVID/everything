  class CStackFrame
    constructor: ({
          @prev
          @receiver, @message, @args
          @definer
          @method
        }) ->

      if not @definer
        found = @receiver.findMethod @message
      else if not @method
        found = @definer.findMethod @message

      @definer ?= found.definer

      @context = createContext {@receiver, @definer}

      throw new Error "Could not create frame from:
        #{util.inspect {
          @prev
          @receiver, @definer
          @message, @args
          @method = @definer.findMethod @message
        }}"
      
    call: (target, message, args) ->
      if found = target.findMethod message
        {definer, method} = found
        newTop = new CStackFrame {prev: @, target, definer, message, args}
        definer

  accessors CStackFrame::,
    sender: -> @prev?.receiver
    caller: -> @prev?.definer

  dispatchSystemEvent = (message, args) ->
    receiver = definer = 0

    if stack = new CStackFrame {receiver, definer, message, args}

  return {CObject, dispatchSystemEvent}
