

    mixin = require './non-cold/mixin'

    MessageReceiver = mixin.define
      name: 'MessageReceiver'
      proto:
        init: (args) ->
          @methods.set {}
          @methodCache = {}

        repo:
          definers: (name) -> @methodNames[name]

          add: (name, definer) ->
            (@methodNames[name] or= new Set).add definer

          remove: (name, definer) ->
            @methodNames[name]?.delete definer

          methodNames: {}

        methods: -> @stateBucket 'methods'

        unfreeze: ->
          @addMethod method for method in @methods

        lookupMethod: (methodName) ->
          methodCache[methodName] or @methods.get()[methodName]

        addMethod: (method) ->
          {name} = method

          if @cantInheritMethod name
            throw new Error "Method name conflict"

          @methods.set @methods.get()[name] = {definer: this, method}
          @repo.add name, this

          for kid in @children
            kid.updateMethodCache this, method

        updateMethodCache: (definer, name, method) ->
          @methodCache[name] = {definer, method}
          
        cantInheritMethod: (name) ->
          if @lookupMethod name
            return true

          if @lookupMethod name
            return true

          for definer in @repo.definers name when definer.hasAncestor this
            return true

    module.exports = MessageReceiver

# old notes

What should happen when someone tries to add a method to a parent which is
already defined on a descendant or a descendant's ancestor? This could get
gnarly.

### Check first

Check all descendants for a conflict, throw an error instead of adding the
method.

- Gives children power of parents which they probably shouldn't have.
- Makes adding methods to heavily shared objects expensive.

### No new methods on objects with children

- Imposes admin cost of having to migrate children to new parent with new
  method.
- Forces change management?
- How to ensure children of different versions of a parent behave well?
 - engineering?

