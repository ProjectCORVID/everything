{ assert, suite, test } = require '.'

suite 'CLI', (suite, test) ->
  { CLI } = require 'cli'

  suite 'Tokenizer', (suite, test) ->
    { Tokenizer } = CLI

    test 'Sends parse results to callbacks', (done) ->
      new Tokenizer cb
        .on 'tokenized', (results) ->
          assert.equal 'object', typeof results, 'result is an object'
          done()
        .accept 'some text'

    test 'Treats unquoted space as a word boundary', (done) ->
      new Tokenizer cb
        .on 'tokenized', (results) ->
          { tokens } = results
          assert Array.isArray tokens
          assert.equal tokens[0].type, 'word'
          assert.equal tokens[1].type, 'whitespace'
          assert.equal tokens[2].type, 'word'
          assert.equal tokens[3].type, 'endOfLine'
          done()
        .accept 'some text'

    test 'Trims leading and trailing spaces', -> (done) ->
      new Tokenizer cb
        .on 'tokenized', (results) ->
          { tokens } = results
          assert Array.isArray tokens
          assert.equal tokens[0].type, 'word'
          assert.equal tokens[1].type, 'whitespace'
          assert.equal tokens[2].type, 'word'
          assert.equal tokens[3].type, 'endOfLine'
          done()
        .accept '   some text   '


    test 'Understands shell quoting', -> (done) ->
      new Tokenizer cb
        .on 'tokenized', (results) ->
          { tokens } = results
          assert Array.isArray tokens
          assert.equal tokens[0].type, 'word'
          assert       tokens[0].quoted
          assert.equal tokens[0].value, 'some \" text'

          assert.equal tokens[2].type, 'word'
          assert   not tokens[2].quoted
          assert.equal tokens[2].value, '\''

          assert.equal tokens[3].type, 'endOfLine'
          done()
        .accept '"some \" text" \' '


