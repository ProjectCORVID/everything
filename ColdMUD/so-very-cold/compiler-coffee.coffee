# Compile ColdMUD-enhanced CoffeeScript to ColdMUD-enhanced JavaScript

cs    = require 'coffeescript'

{ IdentifierLiteral
  Call
} = Nodes = require 'coffeescript/lib/coffeescript/nodes'

example = cs.nodes '''
  (arg) ->
    $ident
    funcCall arg
    target.methodCall arg
'''

module.exports = (code, self) ->
  nodes   = cs.nodes code
  objRefs = {}

  nodes.traverseChildren yes, (node) ->
    switch
      when node instanceOf Call
        # Replace 'foo.bar baz' with 'call foo, "bar", [baz]
      when node instanceOf IdentifierLiteral
        # Replace '$foo'        with 'call $sys, "getObjByName", ["foo"]'

    yes

  compiled = nodes.compile()
