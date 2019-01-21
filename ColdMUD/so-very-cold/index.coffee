vm = require 'vm' # for (sortof) hiding global and providing $sys, definer(), etc.

unrelated = do ->
  {keys}     = Object
  {max}      = Math

  reduce     = (f) -> (l) -> l.reduce (a, b) -> f a, b
  map        = (f) -> (l) -> l.map    (e   ) -> f e

  length     = (o) -> o.length

  longestKey = (o) -> reduce max, (map length) keys o

  accessors = (o, namesAndDefs) ->
    for name, def of namesAndDefs
      Object.defineProperty o, name, get: def

    return o

  {length, longestKey, map, reduce, keys, max, accessors}

# DB is an Array which has a .maybeInit(module) method which uses
# new module.CObject(parentIds) to initialize itself. Initialization should
# ensure the existence of $sys and $root.
#
# compiler is a function taking CoffeeScript source as input and returning
# a String of ECMAScript source, with attached metadata... or something.
module.exports = (DB, compiler) ->
  {length, longestKey, accessors} = unrelated

  ID      = Symbol()
  PARENTS = Symbol()
  DATA    = Symbol()
  METHODS = Symbol()

  class CObject
    @thaw: (sourceLineIterable) ->
      sourceLineIterator = sourceLineIterable()

      o                  = null
      id                 = null
      keyword            = null

      loop
        {done, value: line} = sourceLineIterator.next()

        break    if done
        continue if not (line = line.trim()) or line[0] is ' '

        [keyword, values...] = line.split ' '

        switch keyword
          when 'object'
            if 'object' isnt typeof o = DB[id = values[0]]
              o = new CObject

              if o[ID] isnt id
                o[ID] = id
                DB.pop()
                DB[id] = o

          when 'parents'
            parentIds = values.map (p) -> parseInt p

            o[PARENTS] = parentIds

          when 'var'
            o = o ? new CObject []

            [definer, name] = values

            valueStart      = line.indexOf(' ' + name + ' ') + name.length + 2
            valueJSON       = line[valueStart..]
            value           = JSON.parse valueJSON

            o.set parseInt(definer), name, value

          when 'method'
            [name] = values
            source = []

            while line isnt '.'
              {done, value: line} = sourceLineIterator.next()

              if done
                throw new Error "Reached end of lines in middle of definition of method #{id}:#{name}"

            o.setMethod name, source.join '\n'

    constructor: (parentIds = []) ->
      @[ID]      = DB.push @
      @[PARENTS] = parentIds
      @[DATA]    = {}
      @[METHODS] = {}

    destroy:                      -> DB[@[ID]] = null

    # Intentionally missing: add/remove parent
    #
    # To re-parent a branch you have to re-create all the children under the
    # new parents and update all the references. It will make method caching
    # more efficient and force such changes to be more ops-friendly.

    get: (definerId, name)        -> (@[DATA][definer])?     [name]
    set: (definerId, name, value) -> (@[DATA][definer] ?= {})[name] = value
    delAll: (definerId)           -> (@[DATA][definer]  = {})

    delMethod: (name)             -> @[METHODS][name] = undefined

    setMethod: (name, code)       ->
      if def = compiler code, @
        @[METHODS][name] = def
        @purgeMethodCache name

    purgeMethodCache: (name) ->

    findMethod: (name) ->
      if def = @[METHODS][name]
        return definer: @[ID], method: def

      for parent in @parents
        if found = parent.findMethod name
          return found

      return

    freeze: (lineReceiver) ->
      addLine = (typeAndData) ->
        for type, data of typeAndData
          lineReceiver.write "#{type.padEnd 7} #{data}\n"

      @freezeConstruction addLine
      @freezeData         addLine; lineReceiver.write '\n'
      @freezeMethods      addLine; lineReceiver.write '\n\n'

    freezeConstruction: (addLine) ->
      addLine object:  @[ID]
      addLine parents: @[PARENTS].join " " if length @[PARENTS]

    freezeData: (addLine) ->
      data = @[DATA]

      freezeParentData = (parent) ->
        width = longestKey vars = data[parent]

        for prop, val of vars
          addLine var: "#{parent} #{prop.padEnd width} #{JSON.stringify val}"

    freezeMethods: (addLine) ->
      methods = @[METHODS]

      for name, def of methods
        addLine method: name
        addLine ['  ']: line for line in def.source.split '\n'
        addLine ['.' ]: '\n'

  createContext = (receiver, definer) ->
    contest = accessors {},
      receiver: -> receiver
      definer:  -> definer

  class CStackFrame
    constructor: ({
          @prev
          @receiver, @message, @args
          @definer
          @method
        }) ->

      if not @definer
        found = @receiver.findMethod @message
      else if not @method
        found = @definer.findMethod @message

      @definer ?= found.definer

      @context = createContext {@receiver, @definer}

      throw new Error "Could not create frame from:
        #{util.inspect {
          @prev
          @receiver, @definer
          @message, @args
          @method = @definer.findMethod @message
        }}"
      
    call: (target, message, args) ->
      if found = target.findMethod message
        {definer, method} = found
        newTop = new CStackFrame {prev: @, target, definer, message, args}
        definer

  accessors CStackFrame::,
    sender: -> @prev?.receiver
    caller: -> @prev?.definer

  dispatchSystemEvent = (message, args) ->
    receiver = definer = 0

    if stack = new CStackFrame {receiver, definer, message, args}

  return {CObject, dispatchSystemEvent}
