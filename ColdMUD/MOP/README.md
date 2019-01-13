# So... Joose is dead, Moose is dead...

Is a Meta Object Protocol and supporting library needed?

# What problem(s) are you trying to solve?

I want to make it easier for me to follow my own standards when developing.

- .comment on every class/module
- every module exported as an object rather than a single class or function
- Use CoffeeScript to write CoffeeScript

# Features

## DSL for working with MOP-enhanced objects

```coffee

    create Child: Parent,
      public:
        methodName: (args...) -> # code

      private:
        someVar:  'some starting value'

```

# Questions

## Instantiation vs extension?

Ok, so what's with the whole class/instance dichotomy anyway? JavaScript makes
no overt distinction other than "classes" are defined by a constructor
function. In MOO and such there isn't even that much distinction. $root is the
prototype of its children and there is no $root.constructor.

On the other hand, there's something to be said for 
