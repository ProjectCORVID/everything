(cs       = require 'coffeescript')
  .parser = require 'coffeescript/lib/coffeescript/parser'

createMethod = (nameAndCode) ->
  if not nameAndCode or Object.keys(nameAndCode).length isnt 1
    throw new Error "usage - createMethod methodName: codeString"

  for name, code of nameAndCode
    renameFn name, fn = cs.eval code
    return Object.assign fn, {name, code}

exports.MethodDb =
class MethodDb
  constructor: (@db) ->
    @definers = []

  defineMethod: (definerId, nameAndCode) ->
    fn = createMethod nameAndCode
    (@methods[definerId] ?= {})[fn.name] = fn

    @

  deleteMethod: (definerId, name) ->
    (defined = @methods[definerId]?)[name] = undefined

    if @methodsOn(definerId).length is 0
      @methods[definerId] = undefined

    @

  getMethods: (definerId) ->
    Object.assign {}, (@definers[definerId] or {})

  lookup: ({receiver, name, startAbove = receiver}, seenStart = false) ->
    if seenStart and found = @getMethods(definerId)[name]
      return found

    if receiver is startAbove
      seenStart = true

      for definer in @db.getParents receiver
        if found = @lookup {receiver, name, startAbove}, seenStart
          return found

    return
