events vs streams vs callbacks vs ...

# streams

- inherantly asynchronous
 - good for real I/O
- easy to reason about and work with
- difficult to extend in practice
- normally only 1:1 comms

# callbacks

- harder to reason about
- brittle

# Events

- A special case of callbacks
 - callback is registered separately 0 .. N times
- An example of the listener pattern
- pub/sub is flexible
 - publisher doesn't know or care who's listening
 - listeners don't know or care who else is listening
- standard Node events
 - include an 'event type'
  - type is like a method name, sortof
 - don't offer an "I got it" response
  - (to prevent further publishing/propagation)
  - but maybe that's fine


