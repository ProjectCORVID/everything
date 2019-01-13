EventEmitter = require 'events'

Object.assign module.exports,
  CLI:
    { Tokenizer }

class State
  constructor: (@name, @impl) ->
    @name = @name.toString()

    if 'function' isnt typeof @impl
      throw new Error 'second arg to State constructor must be a Function'

    if @impl.name.startsWith 'bound '
      throw new Error 'second arg cannot be a bound function'
      # ... because then we have no way of fulfilling the contract

    if @machine not instanceof StateMachine
      throw new Error 'third arg to State constructor must be a StateMachine'

    @nextStates =
      stop: @constructor::stop

  enter: (machine) ->
    new Promise (resolve, reject) ->
      try
        resolve (@impl machine) or @
      catch err
        reject err

  stop: Symbol "[#{@constructor.name} #{@name}::stop]"

  transitionToState: (stateName) ->
    @machine.changeState stateName

class StateMachine extends EventEmitter
  constructor: ->
    super arguments...

    @states = new Set

  addState: (state) ->
    return if @states.has state

    @states.add state
    @addState state for name, state of state.nextStates

  examineState: (state, seen = new Set, priors = new Map) ->
    return if seen.has state

    seen.add state

    for name, nextState of state.nextStates
      unless priors.has nextState
        priors.set nextState, []

      unless state in states = priors.get nextState
        states.push state

    { seen, priors }

  analyzeNetwork: ->
    seen = undefined
    priors = undefined

    for state from @states
      {seen, priors} = @examineState state, seen, priors

    { seen, priors }

  reachable: -> @analyzeNetwork().seen

  unreachable: ->
    unreachable = new Set @states

    unreachable.delete state for state from @reachable()

    unreachable

  unreachableFrom: (state) ->
    unreachable = new Set @states

    for state from @reachableFrom state
      unreachable.delete state

    unreachable

  reachableFrom: (state) ->
    seen = new Set
    priors = new Map

    for state from machine.states
      examineState state

    Array.from seen

  start: (state) ->
    unless @states.has state
      throw new Error "State must be regitered before it can be invoked"
      # but why tho

    if @running
      throw new Error "Machine is already running"

    @emit 'enteringState', state

    (@running = state)
      .enter()

      .then (nextState) ->
        if nextState is state.stop
          @running = null
          @emit 'stopped', lastState: state
        else
          @emit 'leavingState', prevState: @running

          setImmediate =>
            @running = null
            @start nextState

      .catch (err) ->
        @running = null
        console.log "Error entering state #{state.name}:", err
        @emit 'error', err


class Tokenizer extends StateMachine
  escapeChars:
    n: -> '\n'
    o: (state, char) ->
      start = state.idx += 2

      digits = digit while (digit = state.text[state.idx++]) in '01234567'

      token =
        type: 'number'
        value: parseInt digits, 8

      state.tokens.push token

  charHandlers:
    '\\': (state, char) ->
      nextChar = state.text[state.idx + 1]

      switch state.type
        when null
          if escaper = @escapeChars[nextChar]
            return escaper state, char
          
          state.type = 'word'
          state.tokenInProgress = nextChar



    alphanum: Object.assign ((state, char) ->
    ), regexp: /^[a-z0-9]/i

  accept: (text) ->
    state =
      { text
        idx             : 0

        type            : null
        tokenInProgress : ''

        tokens          : []
      }

    while state.idx < text.length
      char = text[idxBefore = state.idx]

      if handler = charHandlers[char]
        handler state, char
      else
        for k, v of charHandlers when v.regexp and char.match v.regexp
          v state, char
          break

      if state.idx is idxBefore
        throw new Error "Index did not advance. Probably a bug."
