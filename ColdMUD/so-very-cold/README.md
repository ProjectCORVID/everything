# Our module fu

Modules are used like...

```coffee
    { ExportedClass... } = require 'module'
    ExportedClass.inject {ImportedDependency}
```

And their definitions look like...

```coffee
    module.exports = Object.assign {},
      {
        class ExportedClass
          @imports: imports =
            ImportedDependecy: null

          @inject: (injected) -> Object.assign imports, injected

          constructor: (...) ->
            throw new Error "wtf mate?!" unless imports.ImportedDependency

        #...
      }

```


# Method protocols

## Implementation expectations

The function defining a method handler may expect:

```coffee

    $sys.setMethods exampleObject,
      exampleMethod: (foo, bar, more...) ->
        # named objects
        $sys.log "example"

        # read-only vars

        definer               # class defining the handler
        receiver              # like `this` for Cold objects
        caller                # definer  in calling method/handler
        sender                # receiver in calling method/handler

        # instance var access
        @name                 #  this[DATA][definer][name]
        (child)::name         # child[DATA][definer][name]

        @name         = value #  this[DATA][definer][name] = value
        (child)::name = value # child[DATA][definer][name] = value

        # All method calls are asynchronous

        try
          result = await target.method arg, args...
        catch error
          # do stuff with error

        # also...
        @.privateMethod args...

```

## Changes from CoffeeScript

-     `@member` refers to a private var called `member`
- `obj::member` refers to the private `member` var of `obj`
- `@[nameExpr]` refers to a private var with the name the expression evaluates to
- `$name`       refers to an object     with the given name
- `$[nameExpr]  refers to an object     with the name the expression evaluates to
- 

## Why are method calls asynchronous?

Because we're building in network transparency from the start. The message
receiver may not be on the same VM, so we can't count on its response ever
arriving. It's important that the programmer is aware of this in case it
matters.

Self messaging has to be async as well because the handler shouldn't be
complicated by the possibility that the message was internal:

```coffee

    $sys.setMethods otherObject,
      methodMakingRegularCall: ->
        words = await delegatingObject.delegatedMethod 'from other'

    $sys.setMethods delegatingObject,
      delegatingMethod: ->
        words =       receiver        .delegatedMethod 'from receiver'

      delegatedMethod: (s) ->
        words = s.split ' '

        if sender is receiver
                return words
        else
          await return words

```

There are other good reasons too. Shut up, I'm awesome.
