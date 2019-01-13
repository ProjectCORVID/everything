readline = require 'readline'

Object.assign $sys.ui,
  mode:
    admin:
      handleLine: (line, state = {}) ->

  create: (mode, {input, output}) ->
    state = {input, output}
    rl = readline.createInterface {input, output}

    rl.on 'line', (l) ->
      state = mode.handleLine l, state
