lib = (mod) -> require path.resolve __dirname, 'lib', mod

fs           = require 'fs'
EventEmitter = require 'events'
path         = require 'path'
process      = require 'process'

ChaosMachine = lib     'machine'
ChaosParser  = lib     'parser'

separator = /(?:=|\s+)/

re = (exp) -> exp.toString[1..-2]

# Opportunity: build the regexps rather than hand-coding them
#
# e.g.:
#   endSwitches: '--'
#   verbose:     alternatives '-v', argWithValue '--verbose', optionallySigned number
#   include:     sequence     alternatives('-I', '--include'), oneOrMore filePaths
#
# Could probably be more succinct.
switches =
  endSwitches: ///^    -- $///
  verbose:     ///^    -v |--verbose  (?: #{re separator} ([+-])(\d+))?     ///
  include:     ///^(?: -I |--include) (?: #{re separator} ([^-]{,2}.*))+    ///

module.exports =
class Chaos
  constructor: (options = {}) ->
    {argv, env} = process

    { dictionaries = []
    } = @options = @processOptions {options, process}

    dictionaries.forEach (d) => @addDictionary d

    @machine = @setupMachine()
    @loadFiles()

  # UNRELATED: Refactor out of this file
  matchSwitch: (args, pattern) ->
    matched = null
    argStr  = ''

    for arg, i in args
      argStr += arg

      if not newMatch = argStr.match pattern
        break

      matched = newMatch

    return {
      matched
      argStr
      consumed: arg[..i - 1]
      args: args[i..]
    }

  # UNRELATED: Refactor unrelated parts out of this file
  processOptions: ({options, process}) ->
    {env, argv, stdin, stdout} = process

    { interactive  = true
      inputStream  = stdin
      outputStream = stdout
      verbosity    = 0
      files        = []
    } = options

    [coffee, script, args...] = argv

    while args.length
      switch
        when ({matched, args} = @matchSwitch args, switches.verbose).matched
          [short, sign, number] = matched

          verbose = @processVerbose verbosity, short, sign, number

        when ({matched, args, consumed: @options.include} = @matchSwitch switches.include).matched
          continue

        else
          files = []
          other = []

          for arg in [arg, args...]
            if @isChaosFile resolved = @resolvePath arg
              files = [files..., resolved]
            else
              other = [other..., arg]

          @options.files = @options.files.concat files

    @options = {interactive, inputStream, outputStream}

  # UNRELATED: Refactor out of this file
  processVerbose: (verbosity, short, sign, number) ->
    if short
      verbosity + 1
    else
      switch sign
        when '-' then verbosity - number
        when '+' then verbosity + number
        else                      number

  setupMachine: ->
    machine = new ChaosMachine @

    if @options.interactive
      process
        .on 'SIGINT',  ubreak = @userBreak.bind @
        .on 'SIGTERM', ubreak

      (@parser = new ChaosParser @options.inputStream)
        .on 'token', @processToken.bind @
        .on 'end',       @shutdown.bind @

    machine

  processToken: (token) ->
    @machine.receiveToken token

  shutdown: ->
    if shutdown = @dictionaries.lookup 'shutdown'
      @push shutdown
      @exec()
      setTimeout @forceShutdown.bind(@), @options.shutdownTimeout or 0
    else
      process.exit 0

  forceShutdown: ->
    console.log "graceful shutdown failed, aborting"
    process.abort()
