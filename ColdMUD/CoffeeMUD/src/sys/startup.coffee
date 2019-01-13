process = require 'process'

module.exports = ->
  $sys.ui.create $sys.ui.mode.admin,
    input:  process.stdin
    output: process.stdout

    # port: @options 'port'
    # receiver: @net.login
