###

class Example
  constructor: ->
    # "X delegates to Y and Z"
    combines @, X, Y, Z

class ExampleAspectWithDependencies
  constructor: (@these) ->
    # "Y expects X to delegate to Z"
    needs @, Y, Z

###

module.exports =
  combines: (subject, aspects...) ->
    subject.as ?= {}

    for aspect in aspects
      subject.as[aspect.name] = new aspect subject

    return subject

  needs: (delegate, aspects...) ->
    unless delegate.these?.as
      throw new Error "target has no .these.as"

    delegate.our ?= {}

    for aspect in aspects
      name = aspect.name
      delegate.our[name] = delegate.these.as[name]

    return delegate

