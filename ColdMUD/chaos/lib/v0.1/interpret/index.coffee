###

This should all be implemented in Chaos.

###

{ ChaosBlock } = require './data'

number = string = whitespace = symbol = error = word = null

TOKEN_TYPE_PATTERNS =
  # A comment is anything indented less than four spaces, including blank
  # lines.

  comment:    /((?:\n {,3}[^\n])+)/
  whitespace: /\s+/
  symbol:     /'(\S+)/
  error:      /~(\S+)/
  string:     /// " ( (?: \\.      # an escaped character
                        | [^"\\]*  # any number of characters not in ['\\', '"']
                      )*
                    ) "
              ///
  native:     /// \n ``` ( .*? ) \n
                         ( .*? )
                  \n ``` \n
              ///

  word:       /\S+/

deEscapeString = (string) ->
  chars = string.split ''

  while chars
    char = chars.shift()

    if char is '\\'
      escape chars.shift()
    else
      char

handlers =
  comment:               -> return
  whitespace:            -> return
  symbol:     ([, name]) -> @push @symbol name
  error :     ([, name]) -> @push @error  name
  string:     ([, str ]) -> @push deEscapeString str
  word  :     ([, name]) -> @push @word name
  native:     ([, lang, code]) ->
    lang or= 'coffee'
    compilers = @word 'compilers'

    if not compiler = compilers.lookup lang
      throw new Error "Unknown language '#{lang}'"

    @push @primitive compiler code

# Executed with 'this' bound to a ChaosMachine.
# When testing, call it bound to something which does @do, @base and @push.
module.exports = interpret = (code) ->
  while code.length
    for handlerName, pattern of TOKEN_TYPE_PATTERNS when matched = code.match pattern
      handlers[handlerName] matched
      code = code[matched[0].length..]

number = (n) ->
  base = (@word 'inputBase') or @base 10
  n    = 0

  for char, idx in code
    n = n * base + base.digitValue char

  n
