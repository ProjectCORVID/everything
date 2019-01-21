
CObjectGen  = require 'object'
CStackFrame = require 'stack-frame'

dispatchSystemEvent = (message, args) ->
  receiver = definer = 0

  if stack = new CStackFrame {receiver, definer, message, args}

Object.assign module.exports, {CObjectGen, dispatchSystemEvent}
