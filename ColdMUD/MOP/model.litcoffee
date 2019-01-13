# Why not extend Object?

This approach is fun but dangerous (much like ...). Keeping our changes
contained makes use by others more flexible and not "all or nothing."

If we ever finish the basic functionality we might add an option to "monkey
patch" the core Node and JavaScript classes.

# Model

A Model is a class with extra features.

    Model = (name, info) ->
      { prototype = {}
        features  = -> false
      } = info

      model = Object.assign Object.create(Model.prototype),
        constructor: this
        {name, prototype, features}

      Model.registered[name] = model

    Object.assign Model,

These are methods and properties of Model itself.

      registered: {}

These are the methods and properties for instances of Model, not the instance
methods for instances of a given Model. Model() creates new models. (model =
Model())() spawns an instance of model.

Model::prototype is a function so that it can be used to create instances of
models.

      prototype:
        (info) ->
          instance = Object.create @prototype
          instance.constructor = this

          for iface in @interfaces and iface.init?
            ret = iface.init.apply instance, info

            if 'object' is typeof ret
              instance = ret

        addFeature: (feature) ->
          @chkMethod fn for fName in feature.does
          @addMethod fn for fName in feature.does

        chkMethod: (fn) ->
          if @protected[fn.name]
            throw new Error "Cannot add method #{name}"

        addMethod: (fn) ->
          if fn.protected
            @protected[fn.name] = fn

          this[fn.name] = @constructor.features

    Object.assign Model.prototype,

These are the default/minimum methods and properties on instances of instances
of Model.

      prototype: {}

