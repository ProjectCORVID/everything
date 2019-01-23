
# DB is an Array.
module.exports = (DB) ->
  {length, longestKey, accessors} = require './util'

  ID      = Symbol()
  PARENTS = Symbol()
  DATA    = Symbol()
  METHODS = Symbol()

  normalizeObjectReference = (idOrObject) ->
    id = idOrObject

    if id instanceof Number              then id = id.valueOf()
    if id instanceof String              then id = id.valueOf()

    if 'string' is typeof id             then id = parseInt id
    if 'number' is typeof id             then o  = DB[id] else (o = id; id = o[ID])

    return {o, id}

  resolveObject = (idOrObject) ->
    {o, id} = normalizeObjectReference idOrObject

    if 'object' isnt typeof o
      throw new Error "Could not resolve object with reference provided (#{idOrObject})"

    if o[ID] isnt id
      throw new Error "Object store integrity error: ##{id}[ID] is #{o[ID]}, expected #{id}"

    {o, id}

  obj = (id) -> resolveObject(id).o

  id  = (o)  -> resolveObject(o ).id


  class CObject
    ###
    @thaw: (sourceLineIterable) ->
      sourceLineIterator = sourceLineIterable()

      o = id = keyword = null

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

            o.setHandlers [name]: CMethod.thaw source.join '\n'
    ###

    constructor: (parentIds = []) ->
      @[ID]      = (DB.push @) - 1
      @[PARENTS] = parentIds
      @[DATA]    = {}
      @[METHODS] = {}

    destroy: -> DB[@[ID]] = null

    setParents: (newParents, moreParents...) ->
      newParents = [newParents] unless Array.isArray newParents
      newParents = newParents
        .concat moreParents...
        .map id

      @delAll p for p in @[PARENTS] when p not in newParents

      @[PARENTS] = newParents
      @[DATA][p] = {} for p in newParents
      @

    get:    (definer, name)        -> (@[DATA][id definer] ?= {})[name]
    set:    (definer, name, value) -> (@[DATA][id definer] ?= {})[name] = value
    delAll: (definer)              -> (@[DATA][id definer]  = {})

    delHandlers: (names...)      -> @[METHODS][name] = undefined for name         in names
    setHandlers: (nameAndMethod) -> @[METHODS][name] = method    for name, method of namesAndMethods

    findHandler: (name) ->
      if def = @[METHODS][name]
        return definer: @[ID], method: def

      for parent in @[PARENTS].map obj
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

  Object.assign CObject, {normalizeObjectReference, resolveObject, obj, id}

  return CObject

  #createContext = (receiver, definer) ->
  #  contest = accessors {},
  #    receiver: -> receiver
  #    definer:  -> definer

