
ColdDB       =
CoffeeMethod =
CObject      =

  null


do ->
  { CMethod } = require 'method'

  { NamedObjectStore
    CoffeeMethod
    CObject
  } = Object.assign {},
    require 'db'
    require 'compiler-coffee'
    require 'object'

  CoffeeMethod.inject { CMethod }

objectStore = new NamedObjectStore {CObject, CMethod: CoffeeMethod}
CObject.inject {objectStore}

