# RegExp::toString() includes leading and trailing slashes, so to interpolate
# already-declared regular expressions I'm overriding ::toString to not
# include the slashes unless a true arg is passed (just in case).

origRegExpToString = RegExp::toString
RegExp::toString = (includeSlashes) ->
  s = origRegExpToString.call @
  if includeSlashes
    s
  else
    s[1..-2]

#RegExp::concat = (others...) -> new RegExp ([@.toString()].concat others).join ''

enclosed = (left, right) -> (contents) -> eachOf left, contents, right

list = (itemExpr, sepatators, opts = {}) ->
  { padded            = true
    trailingSeparator = true
    leadingSeparator  = false
  } = opts

  re = if leadingSeparator then /// #{separators} /// else /// ///

  paddedItem = /// (?: #{whitespace} ( #{itemExpr} ) #{whitespace} ) ///

  if tailingSeparator
    paddedItem = /// #{paddedItem} #{separators} ///

    /// #{re} ( #{paddedItem} )* ///
  else
    /// #{re} ( #{paddedItem} (?: #{separators} (#{paddedItem}) )* ) ///

anyOf = (patterns...) -> /// #{ patterns.map((s) -> "#{s}").join "|" } ///

getters = (o, namesAndDefs) ->
  if not (o and 'object' is typeof o)
    throw new Error "First arg to 'getters' must be an object'"

  if not (namesAndDefs and 'object' is typeof namesAndDefs)
    throw new Error "Second arg to 'getters' must be an object'"

  defs = Object.assign {}, ([name]: get: def) for name, def of namesAndDefs

  Object.defineProperties o, defs

# Possibly too clever...
_range = (start, end, interval) ->
  if start >= end
    while start >= end
      yield start
      start += interval
  else
    while start <= end
      yield start
      start += interval

  return

range = (start, end, interval = 1) ->
  if not interval
    throw new Error "What's the big idea?!"

  return [start] if start is end

  (interval = -interval) if (start > end) is (interval > 0)

  _range start, end, interval

Object.assign exports, { enclosed, list, anyOf, getters, range }

GeneratorFunction = (-> yield).constructor

generatorExtensions =
  map: (fn) ->
    loop
      if ({value, done} = @next()).done
        return fn value
      else
        yield  fn value

  forEach: (fn) ->
    until ({value, done} = @next()).done
      fn value

    return

  filter: (fn) ->
    done = false

    until done
      {value, done} = @next()

      continue unless fn value

      if done then return value else yield value

  reduce: (fn, acc, max) ->
    count = 0

    next = @map (el) -> count++; el

    acc = next().value if arguments.length < 2

    if 'number' is typeof max and max < Infinity
      for value from next
        if count >= max
          throw new Error "Generator produced more than #{max} items"

        acc = fn acc, value

    else
      for value from next
        acc = fn acc, value

    return acc

  #length: (max = 1) -> @reduce ((n) -> n + 1), 0, max

  tee: ->
    buffer = []
    buffers = @buffers ?= new Map
    _next = @next.bind @

    tee = ->
      loop
        if buffer.length
          result = buffer.shift()
        else
          result = _next()

          buffers
            .filter ([fn]) -> fn isnt tee
            .forEach ([, b]) -> b.push result

        if result.done
          return result
        else
          yield result

    @buffers.set tee, buffer

Object.assign GeneratorFunction::, generatorExtensions

withIterator = (fn) -> @[Symbol.iterator] fn

for name of generatorExtensions
  Map::[name] = withIterator
  Set::[name] = withIterator
