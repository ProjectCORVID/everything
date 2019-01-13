- Private
 - Method
  - sender() === this()
  - caller() === definer()
 - Prop
  - Per-instance-only visibility

- Protected
 - Method
  - caller() instanceof definer()
 - Prop: no thank you

- Public
 - default

- Other
 - caller() === definer()
  - Not 'private' because instances can reference each other
  - Not 'protected' because only methods defined on this class can access other instances this way

- Static
 - Method
  - No access to self/this; a "utility" method (more like just a function)
  - If constructors inherited from each other 

    shared   = Symbol()
    instance = Symbol()

    privateStaticExample = ->

    privMethod = (fn) ->
      (self, args...) ->
        fn.apply self, args

    privateMethod = priv (args...) ->
      # some code

    privProps = {}

    privProp = (name) ->
      (nameAndValue) ->
        for k, v of nameAndValue
          privProps.push nameAndValue
          curValue = self[instance][member]

          return (self, newValue) ->
            self[instance][member] = newValue if arguments.length
            curValue

    propExample = privProp example: 'example value'

    getProtected = (self, member) ->
      if 'function' is typeof found = self[shared][member]
        found.bind self

      found

    class ClassName
      @publicStatic: ->
      public: ->

      constructor: (info = {}) ->

      usesProtected: (args...) ->
        foo = getProtected @, 'foo'

        foo isProtected: bar

      usesPrivate: (args...) ->
        bar = privateExample.bind @

        bar isPrivate: true

And about that prototypal inheritance...


class Foo extends Bar

foo = new Foo

Object.getPrototypeOf foo
 is 'Foo {}', meaning Foo::

Object.getPrototypeOf Foo
 is '[Function]', meaning Function::

If we were to

class MetaFoo

MetaFoo:: = Foo
metaFoo = new MetaFoo

then

Object.getPrototypeOf metaFoo
 is Foo

If we

class MetaBar extends MetaFoo

metaBar = new MetaBar

class Root

sys = new Root

Constructor | Proto      | An instance
------------+------------+---------
Klass       | Klass::    | klass
Function    | Function:: | ->
Object      | Object::   | {}
Root        | Root::     | sys

------

An object whose instances respond to 'new'

    class MetaClass
      constructor: (name, constructor, proto) ->
        klass = class
          constructor: (args...) ->
            intance = Object.create klass::

        klass:: = proto

        return klass

Usage

    FooClass = new MetaClass 'FooClass', (info = {}) -> # ...

    foo = new FooClass some: 'info'

Why? Because MetaClass::whatever is accessible as ChildClass.whatever

# Granting access to stuff

Classes which cooperate may want to give each other access to their properties.


    subjects = {}

    sym = Symbol 'Cooperator'

    class Cooperator
      constructor: (subjectOrToken, cb) ->
        switch
          when not new.target
            return new @constructor arguments...

          when 'symbol' is typeof subjToken = subjectOrToken
            self = subjects[subjToken]

            if self.token isnt subjToken
              throw new Error "Access violation"

            return self

          when 'object' is typeof subjectOrKey
            if 'function' isnt typeof cb
              throw new Error "Callback missing or not a function"

            @subject = subjectOrKey
            @grants  = {}
            @props   = {}
            @token   = Symbol()

            subjects[@token] =
            @subject[sym] = @

            cb @token

          else
            throw new Error "Class or Callback required"

      access: (instance, grantor) ->
        if instance not instanceof grantor
          throw new Error "That object does not inherit from that class"

        return new Cooperator.Accessor @token, instance, grantor

      grant: (grants) ->
        for propName, grantees of grants
          (if Array.isArray grantees
            grantees
          else
            [grantees]
          ) .forEach (grantee) ->
              unless grantee[sym]
                throw new Error "Grantee is not cooperative"

              grants = grantee[sym].grants[@token] ?= {}
              grants[propName] = true

        return @

    class Cooperator.Accessor
      constructor: (token, @target, @grantor) ->
        throw new Error "Invalid token" unless @subject = subjects[token]
        throw new Error "Access denied" unless @grants()

        @props = (@target[sym] ?= {})[@grantor[sym].token] ?= {}

      grants: -> @subject[sym].grants.get @grantor

      get: (name) ->
        throw new Error "Access denied" unless @grants()[name]

        @props[name] ?= @grantor[sym].props[name]

      set: (name, value) ->
        throw new Error "Access denied" unless @grants()[name]

        @props[name] = value
        return @

Usage:

    fooKey = barKey = null

    accessFoo = (self) -> Cooperator(fooKey).instance self
    n = 0

    class Foo
      constructor: ->
        accessFoo set: n: n++

    Cooperator Foo, (key) -> fooKey = key

    class Bar
      accessFooN: (instance) ->
        Cooperator barKey
          .access instance, Foo
          .get 'n'
 
    Cooperator Bar, (key) -> barKey = key

    Cooperator fooKey
      .addProps n: 'value' #, ...
      .grant    n: Bar

    someFoos = [1..5].map -> new Foo
    someBar = new Bar
  
    console.log someBar.accessFooN someFoos[4]
    # => 4

