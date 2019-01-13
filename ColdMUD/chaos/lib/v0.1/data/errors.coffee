{ErrorDictionary} = require './index'

errors = new ErrorDictionary

E = new Proxy errors,
  get: (target, propName, receiver) ->
    switch propName
      when 'errorsDict' then errors
      when 'errors'     then Object.values errors.words
      when comment      then comment
      else                   errors.lookup propName

errors.define Object.assign {}, [
  class ChaosError extends Error
    @shortName: 'error'

    @chaosName: ->
      @shortName or
        (@name.toLowerCase()
              .replace 'error',    ''
              .replace 'notfound', 'nf')

    @because: (msg, args...) ->
      new @constructor "#{@constructor.name}: #{msg}", args...

    @englishList: (items, conjunction = 'and') ->
      throw new Error "expected at least one item" unless items?.length

      return items[0] if items.length < 2

      items[..-3]
        .concat items[-2..].join " #{conjunction} "
        .join ", "

  class StackUnderflow   extends ChaosError
    @shortName: 'underflow'

  class ExpectationError extends ChaosError
    @because: (got, expected) ->
      super "got #{@got got}, expected #{@listExpectations expectations}"

    @listExpectations: (expected) ->
      @englishList expected, 'or'

  class TypeError        extends ChaosError
    @got: (got) ->
      if got is null
        'null'
      else
        typeof got

  class ClassError       extends ChaosError
    @got: (got) ->
      if got and 'object' is typeof got
        'an instance of ' + got.constructor
      else
        'a primitive value'

  class DivideByZero     extends ChaosError
    @because: (divisor) ->
      super if divisor is 0
              "divisor is zero"
            else
              "divisor is not a number"

  class NameNotFound     extends ChaosError

  class BlockLevelError  extends ChaosError

].map((error) -> [error.chaosName()]: error)...

module.exports = E
