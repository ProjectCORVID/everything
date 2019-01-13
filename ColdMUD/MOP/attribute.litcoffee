# Attribute

An Attribute is a container for state on a Model.

    Attribute = (model, name, defVal, validator = ->) ->
      attr = Object.assign (Object.create Attribute.prototype),
        {name, default: defVal, validator}

    Attribute.prototype = Object.assign {},
      fullName: -> "#{@model.name}:#{@name}"

      set: (value) ->
        if err = validator value
          throw new Error "Validation failed setting #{@fullName()} " + err

        MOP.set @model, @name, value

      get: ->
        MOP.get @model, @name, value
