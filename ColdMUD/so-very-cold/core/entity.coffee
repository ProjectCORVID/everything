object 'euclidic'

parent 'root'

methods
  init: (child) ->
    @setOn child,
      relations: new Set

      subjectOf: new Map
      verbOf:    new Map
      objectOf:  new Map


