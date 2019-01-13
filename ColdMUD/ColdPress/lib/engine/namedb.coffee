class ColdNameDB
  constructor: ->
    @names = {}

  lookup:  (name   ) -> @names[name]
  setName: (name, o) -> @names[name] = o
  delName: (name   ) -> delete @names[name]
  namesOf: (      o) -> name for name, obj of @names when obj is o

