exports.Db =
class Db
  @comment: '''
    I create, number, lookup and destroy objects.
    
    Constructor:
      Takes no args.

    Methods:
        ::create owner, requestSym, [parents]
            Create an object which inherits from the parents list, or an empty
            list by default.
            
            Calls owner.confirmRequest

            Returns a proxy function (not a global.Proxy) which 

        ::destroy
  '''

  constructor: ->
    @objects = []

  create: (parents = []) ->
    id = @objects.length

    @objects.push
      id:      id
      parents: parents
      methods: {}
      vars:    []
      sym:     Symbol "Object ##{id}"

  destroy: (idOrProxy) ->
    id = idOrProxy unless id = idOrProxy.id

    @objects[id] = undefined
