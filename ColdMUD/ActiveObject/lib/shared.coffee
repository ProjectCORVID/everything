keys = Object.keys

identRegExp = /[a-zA-Z_$][a-zA-Z0-9_$]*/

makeError = (name, argNames, message) ->
  argStr = argNames.join ', '
  argExpr = "[$][(](#{argNames.join '|'})[)]"
  message = "`#{message.replace new RegExp(argExpr),
    (all, parts...) -> "$(#{parts[1]})"}`"

  eval """
    class #{name} extends Error {
      constructor(#{argStr}) {
        super(#{message});
      }
    }
  """

merge = (objs...) -> Object.assign {}, objs...

qw = (s) -> s.trim().split /\s+/

Object.assign exports, {keys, makeError, merge, qw, identRegExp}
