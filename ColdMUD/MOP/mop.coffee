###

A word on multiple inheritance:

A common complaint about MI is that a method name inherited from two parents is
ambiguous. I intend to solve that by prohibiting the situation. If you want an
object to have two kinds of .name, use Aspects.

###

# 'Member' is our word for 'attribute', 'variable', 'property', etc.

class Member
  constructor: (args...) ->
    [ @definer
      @name
      @defaultValue
      @initFn = -> @defaultValue
    ] = args...

  toString: ->
    @definer.name + "[" + @name + "]"

  initChild: (self, meta) ->
    meta.my[@name] = @initFn self, meta

class Method
  @definitions: {}

  @definers: (methodName) ->
    @definitions[methodName]?
      .map (def) -> def.definer

  constructor: (@definer, @name, @fn) ->
    (@definitions[@name] or= []).push @

  toString: -> @definer.name + "::" + @name

Meta = Symbol 'MetaObject state'

MOP = (o) -> o[Meta]

Object.assign MOP,
  enhancements: {}

  intensify: (self) ->
    if not MOP(self)
      self[Meta] = meta =
        parents : [] # implicitly messaged via inheritance
        aspects : {} # explicitly messaged via Aspect(instance)
        members : {} # instance var definitions
        methods : {} # instance method definitions

        children: [] # for propagating changes

        self    : self

        my      : {} # private instance state
        our     : {} # protected instance state 

        # Public instance state (discouraged) is in ECMAScript properties on the
        # instance.

        addMember: (name, defaultValue, initFn = -> defaultValue) ->
          member = new Member @, name, defaultValue
          meta.members[name] = member
          member.initChild self, meta

        hasMethod: (method) ->
          meta.lookupMethod(method.name) is method

        # no need to search parents because adding a parent adds all its methods
        # and adding a method to a parent adds it to all children
        lookupMethod: (methodName) ->
          meta.methods[methodName]

        addMethod: (method) ->
          if meta.hasMethod method
            return

          for def in Method.definers method.name
            if meta.lookupMethod method.name
              throw new Error "A method named #{method.name} is already defined on that object or one of its parents"
            if def.hasAncestor @
              throw new Error "A method named #{method.name} is already defined on that object or one of its children"

          meta.methods[method.name] = method

          ctx =
            definer: method.definer
            self: self
            our: meta.our
            my: {}
            fn: fn

          self[method.name] = ctx.fn

        hasAncestor: (parent) ->
          return true if self is parent

          for parent in meta.parents
            return true if MOP(parent).hasAncestor parent

        addParent: (parent) ->
          if meta.hasAncestor parent
            return

          if meta.hasDescendent parent
            throw new Error "Adding parent creates a loop"

          for method in MOP(parent).methods
            if @lookupMethod method.name
              throw new Error "Method name #{method.name} already defined"

            for definer in Method.definers method.name
              if definer.hasAncestor @
                throw new Error "A descendent already defines a methhod named #{method.name}"

          meta.parents.push parent
          MOP(parent).children.push self

          for method in MOP(parent).methods
            meta.addMethod method
