EventData = 'data'
EventEnd  = 'end'

EncodingUTF8 = 'utf8'

EventEmitter = require 'events'

class ChaosParser extends EventEmitter
  @tokenFirstChars:
    Special    : /["~'{}]/
    Number     : /[0123456789]/
    Whitespace : /\s/
    Word       : //             # always matches

  constructor: (@stream) ->
    @buffer    = ''
    @awaiting  = false

    # Possible future optimization:
    #   make @buffer an auto-expanding ring buffer to minimize memory
    #   fragmentation and alloc/free calls
    @stream
      .on EventData, (d) => @tokenizer @buffer = @buffer + d
      .on EventEnd,      => @emit EventEnd
      .setEncoding 'utf8'

  await: (@awaiting) ->

  tokenizer: ->
    if @task
      # More data came in between token parsing events.  Since we already have
      # a tokenization task queued we'll let it handle the data.
      return

    @task = setImmediate =>
      @task = undefined

      return if @awaiting = (@awaiting and @awaiting.call @) and @awaiting)

      return unless @pullToken @buffer

      @tokenizer() if @buffer.length

  pullToken: ->
    type = @identifyToken (s = @buffer.toString())[0]

    @emitToken token if token = @['pull' + type] s

  identifyToken: (char) ->
    (Object
      .entries @constructor.tokenFirstChars
      .find ([type, pattern]) -> char.match pattern)[0]

  emitToken: (token) ->
    @emit 'token', token
    return true

  pull: (type, fn) ->
    (s) ->
      token = @consume fn() and
      [type]: token

  pullSpecial:    pull 'Word'       => 1
  pullWhitespace: pull 'Whitespace' => 1
  pullNumber:     pull 'Number'     => @wordLength s
  pullWord:       pull 'Word'       => @wordLength s

  consume: (length) ->
    return unless length > 0 # ... in case it's an unfinished Word or Number

    [consummed, @buffer] = [@buffer[..length - 1], @buffer[length..]]
    consummed

  wordLength: (str) ->
    str
      .split('')
      .findIndex (c) -> c in @constructor.whitespace

consumeUpTo = (terminator, headLength) ->
  { startFrom = 0 } = @awaiting

  if -1 is idx = @buffer.indexOf terminator, startFrom
    @awaiting.startFrom = @buffer.length
    return

  @trim headLength
  contents = @trim idx - headLength
  @trim terminator.length
  contents

consumeCoffee = (machine) ->
  if code = consumeUpTo '\n```\n'
    machine.push machine.nativeBlock cs.compile code, bare: true

consumeJavaScript = (machine) ->
  # Relies on last brace being on a line by itself.
  if code = consumeUpTo '\n}\n'
    machine.nativeBlock code

consumeString = (machine) ->
  { soFar = '', startFrom = 0 } = @awaiting

  while startFrom < @buffer.length
    switch char = @buffer[startFrom]
      when '\\'
        break if startFrom is @buffer.length - 1

        soFar += escape @buffer[startFrom += 1]

      when '"'
        # Reached the end of the string, yay
        @trim startFrom + 1
        machine.push machine.string @soFar
        return

      else soFar += char

    startFrom++

  # We get here when we run out of buffer without reaching the end of
  # the string.
  return Object.assign @awaiting, {soFar, startFrom}

  ###
  Parsing and output primitives on hold until we get I/O.

  'EMIT': -> @output.write @pop()

  # CoffeeScript block

  '```': ->
    @parser.await consumeCoffee

  WORD: ->
    @parser.await ->
      (@pullWord).Word

  '"': ->
    @parser.await consumeString 'string'

  "'": ->

  ###



(module.exports = ChaosParser)
  .comment = '''
    I implement a variation on the old Chaos interpreter.

    Usage:

        parser = new ChaosParser inputStream
        parser.on 'token', (token) -> do something with token
        parser.on 'end',           -> shutdown

    To consume buffer without tokenizing it:

        parser.await ->
          do stuff with @buffer
          either clear @awaiting or change the buffer length to signal completion
          function will be called every time there is more data until the method signals completion

    The language:

      - literals
        - "blarg"                       // string literal
        - 'blarg is same as "blarg"     // quotes a word
        - ~blarg                        // new Error "blarg"
                                        // All characters are valid in symbols and errors
                                        // except space and newlines.
        - 'a 'b 'c 3 enlist             // ["a", "b", "c"]
        - { code }                      // block literals
        - 12345                         // numbers behave as expected

      - words
        - Anything that doesn't start with ", ', ~, { or a digit
        - Terminated by newline or space, except for the special words used to implement some of the above.
        - Some special words are self-terminating: ' " ~

      - vars
        -   'varName def                // vars start undefined
        -    varName                    // push varName
        -    varName !                  // varName = pop()
        - -> varName                    // varName() ... maybe? (TBD)

      - objects
        - Everything is an object. To work with them the await another token to tell them what to do:
        - Keys are Objects like ECMAScript Maps

        - obj 'member . @               // push obj[member]
        - obj 'member . !               // obj.member = pop()
        - obj 'member ->                // obj.member()
        - 3 1 2 . !                     // Object.assign {}, new Number(1), 2: 3

      - primitive functions
        - Each supported language (ECMAScript, CoffeeScript) will
          - have its own tokens which will bracket code in that language:
          - JS{ JavaScript.statements(andExpressions) \n}\n
          - ``` CoffeeScript.statements andExpressions \n```\n

      - features implemented by the minimum library
        - classes
        - logic and blocks

    Examples:

        { "hello world" -> log . console } 'hello def !
        -> hello

    '''


