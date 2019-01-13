$location = null

verbs =
  _dig: (directionName, destinationName) ->
    exit = $exit.connecting $here, $location destinationName

  dig: (dirAndDest) ->
    @_dig dir, dest for dir, dest of dirAndDest

  go: (dest) ->

  describe: (targetAndDesc) ->
    for targetName, desc of targetAndDesc
      unless target = matchNoun targetName
        say "Don't know what '#{targetName}' refers to"

  location: $location $sys.vr.matchable.matcher $sys.world.locations()

$sys.world.build = (builder) -> builder verbs

$sys.world.build.comment = """
  Usage:

    $sys.world.build (verbs) ->
      {dig, go, describe, matchPlace} = verbs

      go 'sea'
      [[shore, beach]] = dig shore: 'beach'
      go beach
      describe here: '''
          A narrow strip of coarse gray "sand" between steep cliffs and cold
          crashing waves.
        '''
      [[right, dock],
       [left, cave]] =
         dig
           right: 'dock'
           left:  'cave'
"""
