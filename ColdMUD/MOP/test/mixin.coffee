
{ describe, it } = require 'my_node_modules/lib/setup-testing'

describe 'Mixin', (describe, it) ->
  { Mixin } = require '../lib/mixin'

  class Named extends Mixin
    constructor: (info = {}) ->
      if not new.target
        return @_prepInfo info

      { @name, @parent } = info

    ancestors: ->
      if @parent
        [@].concat @parent.ancestors
      else
        [@]

  describe '.addTo class', (describe, it) ->
    it 'augments class', ->
      class Foo

      Named.addTo Foo

      firstFoo = new Foo Named name: 'first Foo'

