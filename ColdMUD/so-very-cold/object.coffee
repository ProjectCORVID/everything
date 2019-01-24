ID      = Symbol()
PARENTS = Symbol()
DATA    = Symbol()
METHODS = Symbol()

module.exports = (DB) ->
  {length, longestKey, accessors} = require './util'

  resolveObject = (idOrObject) ->
    unless   o = DB.lookupId id = idOrObject or
            id = DB.idOf      o = idOrObject
      throw new Error "Could not resolve object with reference provided (#{idOrObject})"

    if o[ID] isnt id
      throw new Error "Object store integrity error: ##{id}[ID] is #{o[ID]}, expected #{id}"

    {o, id}

  obj = (id) -> resolveObject(id).o

  id  = (o)  -> resolveObject(o ).id

  class CObject
    constructor: (parentIds = []) ->
      @[ID]      = DB.add @
      @[PARENTS] = parentIds
      @[DATA]    = {}
      @[METHODS] = {}

    destroy: -> DB.delete @, @[ID]

    parents: -> @[PARENTS].map (p) -> p

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

  Object.assign CObject, {resolveObject, obj, id}

  return CObject



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
