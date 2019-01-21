vm           = require 'vm'
coffeescript = require 'coffeescript'
CSNodes      = require 'coffeescript/lib/coffeescript/nodes'

Object.assign module.exports,
  CMethod: class CMethod
    constructor: (@definer, @name, 
