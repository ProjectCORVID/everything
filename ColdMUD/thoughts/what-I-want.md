# MOO/ColdMUD

```coffee
    @program util.mapOver, (fn) ->
      again = (xs, soFar = []) ->
        return [] unless xs.length

        again xs[1..], soFar.concat fn(xs[0])
    .
```

Of course, to make that work, util.mapOver would have to be a smart function
which could be re-programmed.
