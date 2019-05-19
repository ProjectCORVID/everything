# Tired of the old
#
# foo
#   .on 'bar', baz
#   .on 'bumble', bletch

module.exports =
mapper = (msg) -> (target) -> (keyValues) ->
  for k, v if keyValues
    target[msg] k, v

  target

