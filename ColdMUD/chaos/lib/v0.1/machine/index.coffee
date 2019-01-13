cs = require 'coffeescript'

{ ChaosBlock, ChaosPrimitive, ChaosDictionary
} = ChaosTypes = require './data'

aCharCode = 'a'.charCodeAt 0

allDigits =
  [0..9]
    .map (n) -> n.toString()
    .concat [0..25].map (n) -> String.fromCharCode aCharCode + n

module.exports =
class ChaosMachine
  @ChaosTypes: ChaosTypes
  @Errors: require './errors'

  constructor: ->
    @data    = []
    @return  = []

    @errors  = @E = Dictionary.copy ChaosMachine.Errors
    @symbols = @S = new Dictionary
    @words   = @W = new Dictionary

    @W.define
      # absolute minimal word needed for bootstrapping
      exec: new ChaosPrimitive -> @_exec @pop

      # compiler def needed for bootstrapping
      compilers:
        coffee: (code) -> cs.compile code
        js:     (code) ->

  block:     (list) -> new ChaosBlock list

  base:      (base) ->
    digits:     digits = allDigits[..base - 1]
    pattern:    new RegExp "[#{digits}]*"
    isDigit:    (c) -> c in @digits
    digitValue: (c) -> @digits.indexOf c

  primitive: (fn)   -> new ChaosPrimitive fn

  word:      (w)    ->
    unless 'string' is typeof w
      throw @E.type.because w, 'string'

    @W.lookup w

  do:        (v)    -> v[@mode()] @
  _exec:     (o)    -> new ChaosValue(o).exec @

  mode:             -> if @word 'blockLevel' then 'compile' else 'exec'

  push:      (v)    -> @data.push   new ChaosValue v
  rpush:     (v)    -> @return.push new ChaosValue v

getters ChaosMachine::,
  pop:  -> @data  .pop()
  rpop: -> @return.pop()
  top:  -> @data  .pop()
  rtop: -> @return.pop()



ChaosMachine.comment = '''
    I provide the Chaos execution environment.

    I track the data and return stacks and implement primitives. Words relying
    on 'native' code have 'this' bound to one of my instances so that, for
    example,  @pop and @push operate on the data stack.

    I also manage the dictionaries.

    My external interface is
      ::push,  ::pop,  ::top
      ::rpush, ::rpop, ::rtop

      ::word,  ::exec
  '''
