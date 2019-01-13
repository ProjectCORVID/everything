Aspected = require './aspected'
{ObjStore, Persisted} = require './persistence'
VR = require './vr'

class Player extends VR.Actor
  constructor: (aspects..., @name = 'wiz') ->
    super


