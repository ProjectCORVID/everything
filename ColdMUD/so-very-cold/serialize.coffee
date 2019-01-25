# Methods I had on CObject but have moved here temporarily until it becomes a
# priority.

  freeze: (lineReceiver) ->
    addLine = (typeAndData) ->
      for type, data of typeAndData
        lineReceiver.write "#{type.padEnd 7} #{data}\n"

    @freezeConstruction addLine
    @freezeData         addLine; lineReceiver.write '\n'
    @freezeMethods      addLine; lineReceiver.write '\n\n'

  freezeConstruction: (addLine) ->
    addLine object:  @id
    addLine parents: @parents.join " " if length @parents

  freezeData: (addLine) ->
    freezeParentData = (parent) ->
      width = longestKey vars = @data[parent]

      for prop, val of vars
        addLine var: "#{parent} #{prop.padEnd width} #{JSON.stringify val}"

  freezeMethods: (addLine) ->
    methods = @methods

    for name, def of methods
      addLine method: name
      addLine ['  ']: line for line in def.source.split '\n'
      addLine ['.' ]: '\n'

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

            if o.id isnt id
              o.id = id
              DB.pop()
              DB[id] = o

        when 'parents'
          parentIds = values.map (p) -> parseInt p

          o.parents = parentIds

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
