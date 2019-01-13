# Validator

A Validator constraints the "shape" of values. It is something like a "type"
in other languages, but is also more dynamic. When the value passed to an
invalidator fails the constraint the invalidator returns a string describing
the reason. When the value passes the return is undefined so these tests can
be chained.

    Validator =
      number: (n) ->
        if n is NaN or
           'number' isnt typeof n or
           not n instanceof Number
          "not a number"

      atLeast: (min) -> (n) ->
        Validator.number(n) or
          if n < min
            "below minimum"

      atMost: (max) -> (n) -> Validator.number(n) and n <= max
        Validator.number(n) or
          if n > max
            "above maxium"

      between: (min, max) ->
        lower = Validator.atLeast min
        upper = Validator.atMost  max

        (n) ->
          lower n or upper n

      string: (s) ->
        if 'string' isnt typeof s and not s instanceof String
          "not a string"

      alphanum: (s) ->
        Validator.string(s) or
          if matched = s.match /[^a-z0-9]/gi
            "#{matched.length} non alpha-numeric characters"

      array: (a) ->
        if not Array.isArray a
          "not an array"
