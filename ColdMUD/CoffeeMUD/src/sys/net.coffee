net      = require 'net'
readline = require 'readline'

Object.assign $sys.net,
  session:
    class session
      constructor: ({@server, @socket, @handler = 'login'}) ->
        @buffer = Buffer.from ''
        @rl = readline.createInterface
          input:  @socket
          output: @socket
          primpt: '> '
        @rl.on 'line', @[@handler].bind @
        @handler = new $sys.net.handler.login @

  server:
    class server
      constructor: (@sessionClass = $sys.net.session, @port = 6666) ->
        @connections = []
        (@server = net.createServer())
          .on 'connection', @setupConnection.bind @
          .listen @port

      setupConnection: (socket)
        @connections.push @socketClass.spawn {server: @, socket}

