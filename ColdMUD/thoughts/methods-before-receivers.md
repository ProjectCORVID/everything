# What if it were method-oriented-programming instead of OOP?

The meaning of this is that

    receiver.message parameters...

would be re-jiggered into

    message receiver, parameters...

Instead of adding methods to classes, we would add classes to method
namespaces. This would mean methods could automatically handle null and
undefined in a friendlier way.

A class's definition would include association with a namespace. The
difference would be that the implementation of the method would not be on
object.

# How to change the semantics

How do I translate normal calls into method-first calls?

## Option 1: Value wrapper

I could create a Value class which, through the miracle of Proxy, can receive
any message:

```coffee

    makeLookupHandler = (namespaces...) ->
      get: (target, name, receiver) ->
        # This makes 'proxy._.callOnTarget()' behave like 'target.callOnTarget'
        return target if name is '_'

        # Otherwise search the namespaces given when creating this handler
        for ns in namespaces when 'function' is typeof (f = ns[name])
          return f.bind target

        # throw new ReferenceError "There is no '#{}' method in the object's namespaces"
        undefined

    boxWithFinder = (handler) ->
      (v) -> new Proxy v, handler

    realObj  = name: 'world'
    boxer    = boxWithFinder handler = makeLookupHandler ns = hello: -> "Hello #{@name}!"
    boxedObj = boxer realObj

    boxedObj.hello()

```

I tested the above, and it worked.

So now we have this concept of an unbound method, which is really a generic
handler for messages. It can delegate to other methods as needed.

# The next innovation: namespaces are functions too

```coffee

    makeFinder = ->
      ns = {}

      adder = (nameAndImpl) ->
        for name, impl of nameAndImpl
          ns[name] = impl

      adder.finder = (target, name) ->
        if fn = ns[name]
          (args...) -> fn.apply target, args

      adder

    (greeter = makeFinder())
      hello: -> "Hello #{@name}!"

    anObj = boxWithFinder(greeter.finder) name: 'world'

    anObj.hello()
```

That also works.

# Namespace chaining

```coffee

    makeFinder = (parent) ->
      ns = {}

      adder = (nameAndImpl) ->
        for name, impl of nameAndImpl
          ns[name] = impl

      adder.finder = (target, name) ->
        if fn = ns[name]
          return (args...) -> fn.apply target, args

        parent?.finder target, name

      adder

    (greeter = makeFinder())
      hello: -> "Hello #{@name}!"

      add: (other) ->
        unless 'object' is typeof other and other not instanceof Number
          return NaN

        if value instanceof Number
          box newNumber value + other
        else
          NaN

      target: -> @

    (anObj = boxWithFinder(greeter.finder) 1)
      .name = 'world'

    anObj.hello()
    anObj.add 1
```
