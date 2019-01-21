{keys}     = Object
{max}      = Math

reduce     = (f) -> (l) -> l.reduce (a, b) -> f a, b
map        = (f) -> (l) -> l.map    (e   ) -> f e

length     = (o) -> o.length

longestKey = (o) -> reduce max, (map length) keys o

accessors = (o, namesAndDefs) ->
  for name, def of namesAndDefs
    Object.defineProperty o, name, get: def

  return o

Object.assign module.exports, {length, longestKey, map, reduce, keys, max, accessors}
