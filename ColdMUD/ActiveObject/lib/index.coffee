# Main library loader
#
# NOTE: This module does not follow the usual Node module pattern. Its export
# is a function whose only parameter is a callback which is called with the AO
# namespace as its only parameter.
#
# Also, modules under ./ao export a function which takes a namespace and
# install themselves into it.

{ resolve } = require 'path'
{ exit }    = require 'process'

debug       = (require 'debug') 'ActiveObject'

loadMod     = require './loader'

capitalize  = (s) -> s[0].toUpperCase() + s[1..]

AO          = null

module.exports = (callback) ->
  if 'function' isnt typeof callback
    throw new Error "AO module requires a callback."

  if AO
    debug "required more than once"
    callback AO
    return

  loadMod resolve __dirname, 'AO'
    .then (loaded) ->
      AO = loaded
      AO.set (require './Namespace').Namespace, 'Namespace'
      debug "AO created: " + JSON.stringify AO
      callback AO
    .catch (err) ->
      debug "load failed"

      console.error "Failed to load ActiveObject library: " + err.message + "\n\n" + err.stack

      exit -1
