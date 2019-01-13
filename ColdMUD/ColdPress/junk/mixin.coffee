_ = require 'underscore'

class MixedIn
  constructor: (klass) ->
    instance = Object.create klass.prototype
    instance.constructor = klass

gopn = Object.getOwnPropertyNames

nameOf = (o) -> (o?.name ? o.mixinName).toString()

mixin = (base, mixins...) ->
  for m in mixins
    common = _.intersection gopn(base.prototype), gopn(m.prototype)

    if common.length
      msg = "Cannot mix #{nameOf m} into #{nameOf base}: #{common.length} conflicts"
      throw new Error msg
  
  for m in mixins
    base.mixins[m.name] = m
    Object.assign base.prototype, m.prototype

mixin.define = ({name, proto}) ->
  newMixin = Object.create proto
  newMixin.mixinName = name
