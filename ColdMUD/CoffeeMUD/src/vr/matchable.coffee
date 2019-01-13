module.exports =
  class Matchable extends $sys.vr.root
    @comment: """
      
    """

    matches: (query, opts = {}) ->
      { against: [ 'name', 'description' ]
        partial: true
