# Our module fu

Modules are used like...

```coffee
    { ExportedClass... } = require 'module'
    ExportedClass.inject {ImportedDependency}
```

And their definitions look like...

```coffee
    module.exports = Object.assign {},
      {
        class ExportedClass
          @imports: imports =
            ImportedDependecy: null

          @inject: (injected) -> Object.assign imports, injected

          constructor: (...) ->
            throw new Error "wtf mate?!" unless imports.ImportedDependency

        #...
      }

```

