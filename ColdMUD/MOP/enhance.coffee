# MOP.enhance(classes...)

MOP = require './mop'

Object.assign MOP.enhancements,
  inheritance: (klass) ->
    parents = [
      (klass.isA or [])...
      (klass.isAn or [])...
    ]

    for parent in parents
      MOP.addParent parent, klass

  structure: (klass) ->
    for member in klass.has?
      MOP.addMember member

  delegation: (klass) ->
    for part in klass.composedOf?
      MOP.addAspect part, klass

enhanceClass = (klass) ->
  MOP.intensify klass

  for enhancement in MOP.enhancements
    enhancement.apply klass

MOP.enhance = (classes...) ->
  enhanceClass c for c in classes
