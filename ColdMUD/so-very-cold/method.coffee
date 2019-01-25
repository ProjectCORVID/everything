vm           = require 'vm'
coffeescript = require 'coffeescript'

{ IdentifierLiteral
  Call
} = Nodes = require 'coffeescript/lib/coffeescript/nodes'

module.exports = () ->
  class CMethod
    @comment: """
      I am the base class for compiled methods. Concrete implementations must
      supply a ::compile method which sets @nodes.

      I also manage the method call process.
    """

    constructor: (@source) ->
      { @code
        @args
        @vars
      } = @compile @source

      @context = vm.createContext {}
      @compile()

      @nodes.traverseChildren yes, (node) =>
        switch
          when node instanceOf Call
            # Replace 'foo.bar baz'
            #    with '$ call:      foo, "bar", [baz]
          when node instanceOf IdentifierLiteral
            # Replace '$foo'
            #    with '$ getObject: "foo"'

        yes

      compiled = nodes.compile()

      return {code, args, vars}    call: (frameInfo, args...) ->
      # frameInfo contains {sender, caller, receiver, definer, message}
     
      Object.assign @context, {frameInfo}


  {CMethod}

example = cs.nodes '''
  (arg) ->
    $ident
    funcCall arg
    target.methodCall arg
'''


