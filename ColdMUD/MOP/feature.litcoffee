# Feature

A Feature extends a Model by addition rather than by inheritance. Feature
methods are exposed to 'this' through a moderator object which maps the actual
instance to what the Feature needs from it. @these references the Model's
external form.

    class Feature
      constructor: (@name, info) ->
        { @has          = {}
          @does         = {}
          @consumes     = {}
          @exports      = {}
          @initInstance = ->
        } = info

        Feature.register this

Feature::addToModel returns an object which manages that model's version of
that feature.

      addToModel: (model) ->

    Feature.registered = {}
    Feature.register = (feature) ->
      @registered[feature.name] = feature

    module.exports = {Feature}
