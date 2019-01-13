module.exports = comment """
    I
  """, (engine) ->
    class ColdPressObjectProtocol
      @comment: '''
        My children provide the public interface to a set of ColdPress objects.
      '''

      constructor: (args...) ->
        @db     = new engine.db
        @nameDb = new engine.namedb

## Life cycle

      create:      (parents...)    -> @db.create parents
      destroy:     (o)             -> @db.destroy o

## Identity

      lookupId:    (id)   -> @db.lookup id
      isObj:       (o)    -> o instanceof ColdObjectHandle

      id:          (info) ->
        switch
          when            info is undefined then undefined
          when            info is null      then undefined
          when     @isObj info              then info.id
          when (@lookupId info)?.id is info then info
          when o = @lookupName info         then o.id
          else                                   undefined

## 'Naming'

      lookupName:  (name) -> @nameDb.lookup name

## Inheritance

      getParents:  (o)             -> o.getParents()
      setParents:  (o, parent)     -> o.setParent parent
      getChildren: (o)             -> o.getChildren()
      hasAncestor: (o, a) ->
        return true if o is a

        for ancestor in o.getParents()
          return true if @hasAncestor ancestor, a

        false

      ancestorsOf: (o, known = []) ->
        return known if o in known

        known.push o

        for ancestor in o.getParents() when ancestor not in known
          known = known.concat @ancestorsOf ancestor, known

        known

  delegate = (methods...) ->
    Object.assign {}, (
        for method in methods
          [method]: (target, args...) -> -> target[method] args...
      )...

## Properties

      getProp: delegate 'getProp'
        (o, name) -> o.getProp     name
      addProp:     (o, name) -> o.addProp     name
      delProp:     (o, name) -> o.delProp     name
      listProps:   (o)       -> o.listProps()

      getPropDefinition:
             (definer, name) -> definer.props[name]

## Methods

      addMethod:   (o, nameAndDef) -> o.addMethod nameAndDef
      listMethods: (o)             -> o.listMethods()
      getMethod:   (o, name)       -> o.getMethod name

      matchMethod: (self, definer, name, args) ->
        o.matchMethod arguments...

      invokeMethod: (stack, method, args) ->

    return {COP, ColdPressObjectProtocol}
