module.exports =
class Actor extends Thing
  attempt: (action) ->
    @location.attempt @, action

  considerHypothetical: (event) ->
    return Promise.resolve event
