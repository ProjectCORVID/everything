qw = (s) -> s.split /\s+/

notImpl = -> throw new Error "not implemented"

prevCreation = Symbol 'previously created object'
prevParent   = Symbol 'previously created object\'s parent'

creationInfoFields =
  Object.keys
    instVars:     null
    classVars:    null
    instMethods:  null
    classMethods: null

juggleDefInfo = (info) ->
  break for name, superClass of info
  delete info[name]
  {name, superClass, info}

applyDefinition = notImpl # (o, info) ->

create = (categoriesAndNamesAndClassAndInfo) ->
  created = {}

  for category, nameAndClassAndInfo of categoryAndNamesAndSuperClasss
    for name, info of nameAndClassAndInfo
      {name, superClassInfo, info} = juggleDefInfo info

      superClass =
        switch superClassRef
          when null         then null
          when prevCreation then lastCreated
          when prevParent   then superClass
                            else superClassRef

      lastCreated =
      created[name] =
      Object.assign (Object.create superClass), {name, category}

      applyDefinition lastCreated, info

  created

create.comment = '''
    I am a boot-strapping function.

    My arg is a mapping from categories to objectDefs. ObjectDefs start
    (because object keys are ordered in ES2017) with a key which is the name
    of the object and a value which describes the object's superClass, if any.
    The remaining key/value pairs optionally add instance and class vars and
    methods.

    It looks like this:

        create
          Category:
            { ObjectName: parentInfo
              InstVars: [...]
              ClassVars: [...]
              etc...
            }

        =>
          ObjectName:
            category: 'Category'
            InstVars: [...]
            ClassVars: [...]
            etc...
  '''

createInstanceMethods = notImpl
# (methodInfo...) ->
#   while methodInfo.length
#     nameAndInfoStart = methodInfo.shift()
#
#     for name, infoStart of methodInfo

createInstanceMethods.comment = '''
    I create an InstMethods: object for inclusion in an object definition.

    See createMethods for further details.

'''

createMethods = (methodMap) ->
  for category, [method, argInfo...] of methodMap
    for name, code of method
      break



createMethods.comment = '''
    I create methods which may latter be assigned to objects.

    Much like create(), my arg is a map from categories to definitions.
    However, my definitions are different:

        createMethods
          SomeCategory:
            { methodName: """
                method code
              """, '': argName
              keyword: argName
              keyword: argName
              ...
            }
          NoArgs:
            { noArgs: """ -> 'nothing, why' """ }
          OneArg:
            { oneArg: """ ({anArg}) -> "not #{anArg}, certainly" """
              '': 'anArg'
            }
          TwoArgs:
            { twoArgs: """({a, b}) -> "so basically #{a} and #{b}, then?"""
              '' : 'a'
              and: 'b'


'''

newGlobal = Object.assign {},
  create
    KernelObjects:
      Object.assign { ProtoObject: null }
        createInstanceMethods
          comparing:
            [ '=='              : 'anObject', (self, other) -> self is other ]

          'reflective operations':
            { basicIdentityHash :             notImpl }
            { become            : 'other',    notImpl }
            { cannotInterpret   : 'aMessage', notImpl }

          'class membership':
            { class             :             notImpl }

          # More to come...

      { Object:           prevCreation,
        classVars: ['DependentFields']
      }

    KernelClasses:
      { Behavior:         prevCreation
        instVars:         qw 'superclass methodDict format layout'
        classVars:        qw 'ClassProperties ObsoleteSubclasses'
      }
      { ClassDescription: prevCreation
        instVars:         qw 'instanceVariables organization'
      }
      { Class:            prevCreation
        instVars:         qw 'subclasses name classPool sharedPools
                              environment category traitComposition
                              localSelectors'
      }
      { Metaclass:        prevParent
        instVars:         qw 'thisClass traitComposition localSelectors'
      }

Object.assign newGlobal,
  create
    KernelObjects:
      { Boolean:          newGlobal.Object
        createInstanceMethods
          instanceCreation:
            new: ->
          logicalOperations:
            '&': (other) -> @ and other
