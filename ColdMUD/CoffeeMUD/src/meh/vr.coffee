{ Persisted } = require './persistence'
{ needs, combines } = require './aspect'

VR = {}

defineVr = (klass) ->
  VR[klass.constructor.name] =
    new Persisted

defineVr class Thing
  constructor: ->
    combines @, Container, Located, Observable

defineVr class Actor extends Thing
  constructor: (aspects...) ->
    combines @, Observer, Initiator

defineVr class Observable
  constructor: (@these) ->
    combines @, Visible, Audible, Tactile, Fragrant, Flavored

    needs @, Located, Container

defineVr class Container
  constructor:   (@these)      -> @contents = []

  thingLeaving:  (those, to  ) ->
  thingEntering: (those, from) ->

  thingLeft:     (those, to  ) ->
    @contents = @contents.filter (item) -> item isnt those

  thingArrived:  (those, from) ->
    @contents.push those

defineVr class Located
  constructor: (@these) ->
    @location = undefined

  moveTo: (destination) ->
    @location  .thingLeaving  @these, destination
    destination.thingEntering @these, @location

    @location  .thingLeft     @these
    destination.thingArrived  @these

    @location = destination

