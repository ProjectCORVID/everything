import { ColdDB       } from './cold-db.mjs'
import { CoffeeMethod } from './compiler-coffee.mjs'
import { CObject      } from './object.mjs'

objectStore = new ColdDB {CObject, CoffeeMethod}
(objectStore.lookupName 'sys')
  .call startup: []
