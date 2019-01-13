class GetHandler
  constructor: (@get) ->

class MethodNamespace
  @comment: '''
    I give the illusion of adding methods to objects without changing their inheritance.
  '''

  constructor: (@methods = {}, @warnOnConflict) ->
    @handler = new GetHandler (target, name, receiver) =>
      # This makes 'proxy._.callOnTarget()' behave like 'target.callOnTarget'
      return target if name is '_'

      # Otherwise search our methods
      return @methods[name].bind target

  definesMethod: (name) -> @methods[name] isnt undefined
  hasMethod:     (name) -> @methods[name] isnt undefined
  methods:              -> Object.keys @methods
  makeBox:          (v) -> new Proxy v, @handler

  setHandlers: (namesAndFns) ->
    for name, fn of namesAndFns
      @methods[name] = fn

  removeHandlers: (names...) ->
    for name in names
      @methods[name] = undefined

Object.assign exports, {GetHandle, MethodNamespace}

if not typeof demo
  (ns = new MethodNamespace)
    .setHandlers hello: -> "Hello #{@name}!"

  realObj  = name: 'world'
  boxedObj = ns.makeBox realObj

  console.log boxedObj.hello()
