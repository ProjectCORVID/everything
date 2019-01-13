describe = (comment, o) -> Object.assign o, {comment}

ns = describe """
    I map a directory tree to an object.

    Example:

        ns  = require 'ns'

        lib = ns 'lib'
        lib.foo 'bar' # equivalent to (require 'lib/foo') 'bar'

  """, (dir) ->

biolerplate = describe """
    Gives a module a way of installing itself.
  """, (target) ->



