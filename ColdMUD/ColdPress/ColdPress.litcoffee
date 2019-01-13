# CoffeeScript with ColdMUD assumptions?

## ColdMUD assumptions

- All changes to objects persisted at end or suspension of task.
 - Task execution starts with user input or system tick event

## ColdObjRef

In order to simplify messaging, ColdObjects view each other through references
unique to each relationship. The reference knows who the sender and caller
are and constructs the message accordingly. Even self-messaging goes through a
reference so that the definer knows who the sender is.

    class ColdObjRef
      constructor: ({@referrer, @referred}) ->
      
      createMessage: (methodName, args, sender = @referrer) ->
        new ColdMessage
          sender: sender
          caller: @referrer
          methodName: methodName
          args: args
          self: @referred
          definer: @referred.matchMethod @referrer, methodName, args

