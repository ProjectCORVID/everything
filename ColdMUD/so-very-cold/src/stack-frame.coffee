module.exports = (DB) ->
  $sys = DB[0]

  class CStackFrame
    @dispatchSystemEvent: (message, args) ->
      receiver = definer = $sys

      if stack = new CStackFrame {receiver, definer, message, args}
        throw "CStackFrame.dispatchSystemEvent not implemented..."

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
      else unless @method = @definer.findMethod @message
        throw new Error "Could not create frame from:
          #{util.inspect {
            @prev
            @receiver, @definer
            @message, @args
          }}"

      #@context = createContext {@receiver, @definer}
      #...
      
    call: (target, message, args) ->
      if found = target.findMethod message
        {definer, method} = found
        newTop = new CStackFrame {prev: @, target, definer, message, args}
        definer

    #accessors CStackFrame::,
    #  sender: -> @prev?.receiver
    #  caller: -> @prev?.definer

