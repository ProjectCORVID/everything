confInfo = Symbol()

Object.assign exports,
  comment: '''
    These functions provide methods with a way of associating an identity with a caller.

    This module provides authentication (authn), but not authorization
    (authz).  It is up to the receiver to decide which objects/functions they
    will accept calls from.
  '''

  makeReceiver: (obj, fnName) ->
    unless 'function' is typeof fn = obj[fnName]
      throw new Error 'wat'

    Object.defineProperties fn,
      [confInfo]:
        getAuth: (sender) ->
          sender[confInfo]?.giveAuth 

