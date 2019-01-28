# Some sample code

$thing.setMethods
  init:        ->
    
  environment: ->
  move: (dest) ->

$room.setMethods
  description: (perceiver) ->
    for neighbor from @environment()
      for perception from neighbor.descriptionImpact described: @
        perceiver.queueExperience perception

