# Simple readline interface for experimentation

readline = require 'readline'

cs       = require 'coffeescript'

global.rl = readline.createInterface
  input:  process.stdin
  output: process.stdout

rl.prompt()

prefixes =
  '!': (line) ->

  ';': (line) ->
    if line.startsWith ';'
      (line) ->
      try
        console.log cs.eval line[1..]
        true
      catch e
        console.log e

fail = (line) ->
  console.log "No processor found for '#{line}'"

rl.on 'line', (line) ->
  console.log "Got: #{line}"

  do ->
    for pfx, handler of prefixes
      continue unless line.startsWith pfx
      console.log "Saw prefix #{pfx}"

      return result if result = handler line[pfx.length..]

    fail line

  rl.prompt()
