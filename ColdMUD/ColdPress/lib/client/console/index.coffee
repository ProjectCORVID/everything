# ColdPress console client library
#
# Usage:
#
#     coffee -e <<EOF
#       {stdin: input, stdout: output} = process
#       lib    = require 'lib'
#
#       core   = require 'core'
#       world  = core lib.COP lib.engine
#       client = lib.client.console {input, output, world}
#     EOF
#
# ... or something?

readline = require 'readline'

module.exports = ({input, output, world}) ->
  avatar = world.lookup 'wizard'
  rl = readline.createInterface {input, output, prompt: '> '}
  avatar.addReadline rl

  # avatar.on 'echo',         (output) -> rl.write              output
  # avatar.on 'changePrompt', (prompt) -> rl.setPrompt          prompt
  # rl.on     'line',         (line)   -> avatar.receiveCommand line   ; rl.prompt()

  # rl.prompt()
