# Thinking about more natural streams/pipes.

lineReceiver = new 

class Pipe
  constructor: (info = {}) ->
    @accepted = []
    @sent = []
    @deliveryTask = null

  connect: (@sink) -> return @

  accept: (message, cb) ->
    @accepted.push { message, cb }
    @scheduleDelivery()
    cb {message, status: 'accepted'}
    return @

  @receiveUpdate: (message, details = {}) ->
    if details?.message? isnt message
      throw new Error "Unexpected update"

  attemptDelivery: ->
    { message, cb } = @accepted.shift()

    receiveUpdate = @constructor.receiveUpdate.bind @, message

    try
      @sink.accept message, receiveUpdate
      cm {message, status: 'sent',
    catch e
      status = 'error invoking destination.accept'
      retryable = false
      cb {message, status, retryable}

  scheduleDelivery: ->
    return if @deliveryTask

    @deliveryTask = setTimeout (
      @deliveryTask = null
      =>
        [msg, @pending] = @pending

        @scheduleDelivery() if @pending.length

        statusCallback = (status) ->
        @sink.accept msg, statusCallback

        if err.retryable
          @pending.push msg

        try
          @errorsTo {err, message, @sink}
    ), 0

    return @

# pass messages to two sinks
class Pipe.A extends Pipe

# pass messages from two sources to one same sink
class Pipe.V extends Pipe

# Throttle message passing
class Pipe.Valve extends Pipe

# Sort
class Pipe.Grate extends Pipe
  constructor: (info = {}) ->
    super info
    { @predicate } = info


