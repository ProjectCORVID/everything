module.exports = (COP) ->
  class ColdObjectHandle
    @comment: '''
      I am the internal interface to a ColdPress object. My current
      implementation makes no distinction between a handle and the object
      itself. A future version will decouple these concepts.
    '''

    constructor: (@db) ->
