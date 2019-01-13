(cs       = require 'coffeescript')
  .parser = require 'coffeescript/lib/coffeescript/parser'

state     = []
methods   = []

nameDb    = {}

renameFn = (name, fn) ->
  Object.defineProperty fn, 'name', configurable: true, value: name
  return

createObject = (vars, methods) ->
  id = db.length

  db.push o = (methodNameAndArg, args...) ->
    for method, arg of methodNameAndArg
      if found = lookupMethod id, method
        {definer, fn} = found

        return fn.apply self, args, methods

      break

    throw new Error "Method not found"

  o.id = id
  state[id] = [id]: vars
  o

sys = createObject {},
  create: (parents = [lookup 'root']) ->
    createObject...

root = create (parents: []),
  addVar:     (name, value) -> @$ sys: addVar:     name, value
  getVars:    (           ) -> @$ sys: getVars:    null
  delVar:     (name       ) -> @$ sys: delVar:     name
  addName:    (name       ) -> @$ sys: addName:    name
  getNames:   (           ) -> @$ sys: getNames:   null
  delName:    (name       ) -> @$ sys: addName:    name
  addMethod:  (name, fnDef) -> @$ sys: addMethod:  name, fnDef
  getMethods: (           ) -> @$ sys: getMethods: null
  delMethod:  (name       ) -> @$ sys: delMethod:  name

###

# Some words about methods

When called, 'this' is bound to an object which has properties representing
the state of the object in the context of the method's implementing object.

It also has two special properties:

- '$' is set to a function is the global accessor function. It takes a
  key/value pair as a minimal arg. The key is used as the name of an object
  and the value is another object whose only key is a method name. In other
  words:

      @$ root: addMethod: arg

  is approximately equivalent to

      lookup('root').addMethod arg

  Further, the called method is bound to an object defined as...

- '@' is set to the function which proxied the method call.

###
