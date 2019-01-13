    module.exports = ({COP}) ->
      vm           = require 'vm'

      CoffeeScript = require 'coffee-script'
      csNodes      = require 'coffee-script/lib/coffee-script/nodes'

      { Call, Value, Identifier, Block
      }            = csNodes

## transformNodes

ColdPress differs from CoffeeScript in that method calls are routed through
the ColdPress Object Protocol. The transformNodes function performs this magic
at compile time.

      wrapCall = (node) ->
        unless node.constructor is Call
          return node

        new Call (new Value new Identifier '$call'), [node], false

      transformNodes = (nodes, transforms) ->
        for branch in nodes.children
          nodes[branch] = nodes[branch].map (n) -> transformNodes n, transforms

        for transform in transforms
          nodes = transform nodes

        nodes

## ColdMethod

Methods have several aspects. At the lowest level they are book-keeping and
wrapping to enable the ColdPress method semantics. At the next level they are
an ECMAScript function generated from some ColdPress code. When matched at run
time they have an invokable aspect.

The ColdMethod class is the first of these.

      class ColdMethod
        constructor: (info) ->
          { @definer, @name
            @code = ""
          } = info

          {@fn, @params} = @compile @code

        @compile: (code) ->
          ast = CoffeeScript.nodes code

          unless ast.constructor is Block and
              ([code] = ast.expressions).length is 1 and
              code.constructor is Code
            throw new Error "supplied code is not in the form of a function literal"

          {params, body} = ast

          body = transformNodes body

          {params, fn: body.compile {}, 0}

        match: (name, args) -> name is @name

        call: (stack, args) ->
          {receiver, definer} = stack.top

          sandbox = Object.create receiver.data.get(definer),
            $root: value: COP.lookupId 1
            $sys:  value: COP.lookupId 0
            $call: value: COP.invokeMethod.bind sandbox, stack


#### addMethod

... is particularly important as the method wrapper has a lot of work to do:

- at time of add
 - create sandbox
 - compile CoffeeScript to AST
 - modify AST
  - modify Call nodes to turn 'foo args...' into $call foo args...
- before wrapped function
 - update stack
 - init sandbox
  - set $caller et al
- after wrapped function
 - find and save field changes
 - update stack

