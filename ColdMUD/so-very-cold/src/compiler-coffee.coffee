# Compile ColdMUD-enhanced CoffeeScript to ColdMUD-enhanced JavaScript

cs = require 'coffeescript'

module.exports = ({CMethod}) ->
  class CoffeeMethod extends CMethod
    compile: -> @nodes = cs.nodes @source

  { CoffeeMethod }

