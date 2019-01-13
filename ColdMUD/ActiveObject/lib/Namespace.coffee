{ keys, makeError, identRegExp
} = require './shared'

debug = (require 'debug') 'AO::Namespace'

KeyExists         = makeError 'KeyExists'         , ['fullPath', 'key' ], "Key '\#{fullPath}::\#{key}' already exists"
InvalidIdentifier = makeError 'InvalidIdentifier' , ['identRegExp'     ], "Identifier '\#{identRegExp}' is invalid"
UnknownNamespace  = makeError 'UnknownNamespace'  , ['namespace'       ], "Unknown namespace '\#{namespace}'"
NotABranch        = makeError 'NotABranch'        , ['fullPath', 'key' ], "'\#{fullPath}::\#{key}' is not a Namespace branch"

identRegExp = /[a-zA-Z_$][a-zA-Z0-9_$]*/

exports.Namespace =
class Namespace
  @comment: '''
    I exploit the :: shortcut of CoffeeScript to provide namespaces using :: as
    their separators.

    Using :: means we can use . for messages to a given level of a namespace as long as the message name isn't "prototype".

    Construction:
        Example = makeNamespace 'Example'

    Methods:
      ::add - extend a namespace, creating sub-keys as needed

        Example.add
          Foo: 'bar'
          Baz: Bumble: (world) -> "hello #{world}"

        console.log Example::Foo
    => "bar"

        console.log Example::Baz::Bumble 'world'
    => "hello world"

      ::parent - parent namespace, if any

        bumble = Example::Baz::Bumble
        console.log bumble.parent
    => "Baz"

      ::fullPath - Returns a string which probably matches the in-code full path to the namespace in question, including its parents

        console.log bumble.parent.fullPath
    => "Example::Baz"

    Note that methods prefixed with underscore are direct operations (no branch traversal).
  '''

#   @pathFromString: (str) ->
#     unless str.match /// ^ #{identRegExp} ( :: #{identRegExp} )* $ ///
#       throw new InvalidIdentifier str
#     
#     parts = str.split '::'
# 
#     try
#       root = eval "#{parts[0]}"
#     catch e
#       throw new UnknownNamespace parts
# 
  constructor: (@name, @parent) ->
    @prototype = {}

  _get:      ( key        ) -> @prototype[key]
  _set:      ( key, value ) -> @prototype[key] = value
  _del:      ( key        ) -> @prototype[key] = undefined
  _have:     ( key        ) -> undefined isnt @_get key
  _isBranch: ( key        ) -> @_get(key) instanceof Namespace

  get:       ( key, keys... ) ->
    v = @_get key

    switch
      when not v            then throw new KeyNotFound @fullPath, key
      when not keys.length  then v
      when not @_isBranch v then throw new NotABranch @fullPath, key
      else                      v.get keys...

  has:   ( key, keys... ) ->
    return false unless branch = @_get key

    return keys.length is 0 or branch.has keys...

  isBranch: (key, keys...) ->
    unless branch = @_get key
      return false

    if keys.length is 0
      return branch instanceof Namespace

    branch.isBranch keys...

  add: (value, keys...) ->
    keys = @_normalize keys

    if @has keys
      throw new KeyExists @fullPath, keys[-1..][0]

    @set value, keys...

  set: (value, keys...) ->
    [keys..., key] = @_normalize keys

    ns = @

    for key in keys
      if undefined is exists = ns._get key
        ns = ns._set key, new Namespace key, ns
        continue

      if exists instanceof Namespace
        ns = exists
        continue

      throw new KeyExists ns.fullPath, key

    debug "Assigning to #{ns.fullPath}::#{key}"

    ns._set key, value

  _normalize: (keys) ->
    return [] unless keys.length

    [].concat (
      for key in keys
        key.split '::'
    )...

  del: (key, keys...) ->
    if not keys.length
      return @_del key

    if not @_isBranch key
      return

    @_get(key).del keys...

Object.defineProperties Namespace::,
  fullPath:
    get: ->
      prefix = if @parent then @parent.fullPath + "::" else ""
      prefix + @name
