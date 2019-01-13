_Props to Colin McCormic for the inspiration._

# In a way, objects are isomorphic to functions with closures.

- Object state can be implemented via closure variables.
- The first arg to an object can be treated as the message name.

```coffee

Object.toString = (v) ->
  switch
    when v is null      then 'null'
    when v is undefined then 'undefined'
                        else v.toString()

(cs = require 'coffeescript')
  .parser = require 'coffeescript/lib/coffeescript/parser'

Block = (cs.parser.parse '').constructor

MethodNF = null

objectMaker =
  f: = (state, methods) ->
    (method, args...) ->
      if fn = methods[method]
        return fn.call fn, state, args, methods

      throw new MethodNF "Method not found"

  o: = (state, methods) ->
    Object.assign {}, state, methods


fnRoot = objectMaker.f {}, do ->
  addMethod:  (state, [fnDef      ], methods) -> (methods[name] = cs.eval fnDef).code = code; return @
  addVar:     (state, [name, value], methods) -> state[name] = value
  getMethods: (state, [           ], methods) -> Object.assign {}, methods
  getVars:    (state, [           ], methods) -> Object.assign {}, getVars

class MethodNF extends Error
  constructor: (target, methodName) ->
    objStr = (target?.name? and "'#{objStr}'") or 'receiving object'
    super "Method '#{}' not found on #{objStr}"
