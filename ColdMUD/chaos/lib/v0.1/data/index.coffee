{getters} = require '../util'

E = null # To be set after exporting ErrorDictionary

class ChaosValue extends Map
  @values:  new Map
  @objects: new WeakMap

  @comment: '''
      I define the default compile and execute behaviors of all values.

      Anything which can exist on a stack is a value. That includes slots and
      blocks. All values objects have an actual primitive value as well as
      optional map entries. The actual value is never itself a ChaosValue
      because that would be redundant. A primitive value only ever has one
      ChaosValue wrapper at a time.
    '''

  from: (value) ->
    switch
      when 'function' is typeof value  then new ChaosPrimitive value
      when value instanceof ChaosValue then value
      else                                  new ChaosValue value

  constructor: (value) ->
    super value

    return switch
      when value instanceof ChaosValue  then value
      when ChaosValue.values.has  value then ChaosValue.values.get value
      when ChaosValue.objects.has value then ChaosValue.objects.get value
      else
        @value = value

        ( if value isnt null and 'object' is typeof value
            ChaosValue.objects
          else
            ChaosValue.values
        ).set value, @

        @

  delete: -> ChaosValue.values.delete @value

  exec:    (machine) -> machine.push @
  compile: (machine) ->
    unless (top = machine.top) instanceof ChaosBlock
      throw new E.compile

    top.push @

class ChaosLValue extends ChaosValue
  @comment: '''
  '''

  constructor: (@location, @name, value) ->
    @set value if arguments.length > 2

class ChaosBlock extends ChaosValue
  constructor: (items = []) ->
    unless Array.isArray items
      throw new E.class items, 'Array'

    super items

  exec: (machine) -> @value.map (item) -> item.exec machine

class ChaosImmediateBlock extends ChaosBlock
  compile: (machine) -> @exec machine

class ChaosPrimitive extends ChaosValue
  exec:    (machine) -> @value.call machine

class ChaosImmediatePrimitive extends ChaosPrimitive
  compile: (machine) -> @exec machine

class ChaosProperty extends ChaosLValue
  set:  (value) -> @location.set @name, value
  get:          -> @location.get @name

class ChaosSlot extends ChaosLValue
  @comment: '''
      I am a reference to a dictionary entry.

      Slots are the closest thing Chaos has to variables. They have a
      dictionary and a name. Their value is the value of that name in that
      dictionary.

      Unlike Forth, Chaos doesn't distinguish between variables and words.
    '''

  set: (value) -> @location.words[@name] = value
  get:         -> @location.words[@name]

class ChaosDictionary
  @comment: '''
      I map word names to slots.
    '''

  @copy: (other) -> (new Dictionary).define other.words

  constructor: -> @words = {}

  lookup: (word) -> new ChaosSlot @, word
  delete: (word) -> @words[word] = undefined; @

  define: (defs) ->
    Object.assign words, defs

    return @

comment = '''
  I catalog the ChaosError classes

  Usage:

      E = require 'errors'

      throw E.example.because reason
'''

class ErrorDictionary extends ChaosDictionary
  lookup: (name) ->
    if found = super(name)
      return found

    namePattern = new RegExp name, 'i'

    for chaosName, error of @words when error.name.match namePattern
      return error

    return

Object.assign module.exports, {
    ChaosValue
    ChaosBlock
    ChaosImmediateBlock
    ChaosPrimitive
    ChaosImmediatePrimitive
    ChaosDictionary
    ChaosSlot
    ErrorDictionary
  }

E = require './errors'
