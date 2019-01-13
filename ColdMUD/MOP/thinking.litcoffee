# The ideas

## Kinds of OO

- Isolation of interface from implementation
- Messages instead of function calls
- Polymorphism
- Inherited state
- Inhertied behavior
- Type algebra nonsense
- Templates?

## Constructor vs Class

## Things I'd like to explore

### Making all object also be functions

    unless typeof example
      makeObj = (parent) ->
        child = (args...) ->
          if 'function' is typeof child.fn
            (child.fn.bind child) args...

### Message target class polymorphism

In a MUD, a player exists as a user of the system with permissions and
out-of-character activities and also as zero or more in-character avatars.

Should the 'aspects' of an object be properties of the instance? Or should the
instance hand out proxies for itself to callers who discover it, so that said
proxies serve as the faces of that object in each of its many contexts?

The latter sounds more flexible and powerful, so let's consider that...

A MUD user has some sort of authentication of one or more factors, configuration
in terms of the one or more protocols the user uses to interact with the world,
permissions outside the context of the game, and avatars she has access to
within the context of the game. An Avatar is an object in the world which
conforms to the worlds rules and which has some sort of "will". The will is
guided by zero or more users at any given time.

Suppose a user is controlling an avatar on a beach and a freak wave pulls the
avatar out to sea. The environment will address the avatar as a rag doll with
physical behaviors and limitations. The avatar will convey the events to the
"will" system as sensations. The will system will by default have feelings about
these sensations (joy, panic, whatever), but will also convey them to the user
filtered through the avatar's limited perspective.

So far none of this is multi-faceted... hm.

### Method signature polymorphism

    unless typeof example
      PolyMethod = (signatures = {}) ->
        meth = (args...) =>
          argDesc = describeArgs args

          if exact = signatures[argDesc]
            return (exact.fn.bind @) args...
          else
            for key, sig of signatures
              if sig.match argDesc
                return (sig.fn.bind @) args...

          if sig = signatures.default
            (sig.fn.bind @) args...
          else
            throw new Error "method not found"

## Meta-Object-Protocol

MOP.enhance(classes...) loops through eah class looking for class properties
which define the class:

- isA: [ parents ]
  - The resulting class is sum of the parents
- does: [ roles ]
- has: [ oneToOne, [ oneToMany ] ]
- belongsTo: [ manyToOne, [ manyToMany ] ]
- does: [ methodName: method ]
- composedOf: [ aspect ]
  - adds functionality by delegation
  - An object is addressed in terms of an aspect via

    unless typeof example
      Aspect(instance)[method](args...)

### Aspects

An aspect (or maybe facet? role? ... need to decide on terminology) is a feature
of an object which may only be axdressed explicitly.

    unless typeof example
      Aspect(instance)[method](args...)

Within the implementation of an aspect, 'this' refers only to that aspect of the
composed object. @self is a reference to the composed object for so-called
self-messaging. @my is a dictionary of private state. @our is a dictionary of
@self-wide state.

    class Aspect
      @symbol: Symbol 'Aspect'

      constructor: ->
        @my = {}
        @custructor.symbol or= Symbol @constructor.name

      addToInstance: (@self) ->
        @self.aspects[@constructor.symbol] = @
        @our = @self.our

    class Aspected
      constructor: ->
        @our     = {}
        @my      = {}
        @aspects = {}

      addAspect: (aspectClass) ->
        (new aspectClass).addToInstance @, @our

## ColdMUD semantics

- Multiple inheritance
- Instance state only visible to definers

# Weirdness

Declaring these here to be replaced with implementations later:

    ParentManager =
    MethodManager =
    AttributeManager = null

I'm using a symbol to hide object's meta-selves from non-MoP usage. This is not
to keep other objects from intentially modifying the state, but to keep the
state from conflicting with the non-meta interface of objects.

    MetaClass = Symbol 'MetaClass'

# Models

## MetaObject

MetaObject provides the facilities for defining and using classes. A MetaObject
handles messages addressed to an object's existance as an object. A given
object's 

    class MetaObject
      constructor: (@metaClass = MetaObject) ->
        @parents    = new ParentManager    @
        @methods    = new MethodManager    @
        @attributes = new AttributeManager @

      addParent: (parent)           ->    @parents.add parent
      addMethod: (name, fn)         ->    @methods.add name, fn
      addAttribute: (name, options) -> @attributes.add name, options

      fromECMAObject = (subject) ->
        mClass = new MetaObject

## MOP()

MOPInstance defines the behaviors of objects when they are treated as normal
ECMAScript entities. ECMAScript makes no distinction between classes and
instances, and neither does the MOP, so a given entity could be addressed as one
or the other at a given time. We treat "normal" operations as non-meta and
provide a MOP function to give us a way to access an object's "meta" self.

    MOP = (subject) ->
      subject[MetaClass] ?= MetaObject.fromECMAObject

