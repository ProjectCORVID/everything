Object.assign $sys.cli,
  parser:
    class parser
      constructor: ({@context, @next}) ->
        super arguments...

      parse: (text) ->
        @_parse(text) or @next?.parse text


