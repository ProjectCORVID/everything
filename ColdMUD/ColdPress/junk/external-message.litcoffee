## ExternalMessageEvent

- Object messages are asynchronous
 - Data changed before message processing has resolved is not persisted or
   exposed to other "threads"
 - A "thread" is associated with an external event
  - network, timeout, process signal, etc
 - At the start of a message event, the event gets a unique ID and a pointer
   to a version of the knowledge tree at the start of the thread
 - Changes within the event (including outbound I/O) are saved up until it
   reaches some sort of conclusion:
   - timeout
   - out of "ticks"
   - originating Promise resolved or rejected

    class ExternalMessageEvent
      constructor: ({@db, @message, @timeout = 1000}) ->
        @id = Symbol()
        @worldView = @db.snapshot()
        @changes = []
        @rolledBack = @committed = false

      start: ->
        @timeoutTask = setTimeout @timedOut.bind(this), @timeout

        @message.send via: this
          .then      => @commit()
          .catch (e) => @rollback e

      commit: ->
        if @timeoutTask
          clearTimeout @timeoutTask
          @timeoutTask = undefined

        if @committed
          return

        if @rolledback
          throw new Error "Can't commit, already rolled back"

        try
          newWorld = @db.logChanges @changes
          @committed = true
        catch e
          @rollback e
          return

        try
          @message.reply result: newWorld

      rollback: (e) ->
        if @rolledback
          return

        if @committed
          throw new Error "Can't roll back, already committed"

        @rolledBack = true
        @message.reply error: e

      timedOut: ->
        @rollback new Error "Event ran out of processing time"

