# Depends on COP.addMethod setting up wrappers which define functions which
# setup the instance-specific environments.

COP = null

dis_over = (f) -> Object.assign f, disallow_overrides: true

props    = (definer, namesAndSuch) ->
  COP.
  definer.defineProp [name]: info for name, info of namesAndSuch

set      = (target, definer, namesAndValue) ->
  target.setProp definer, [name]: value for name, value of namesAndValue

method = (obj, namesAndDefs) ->
  COP.addMethod obj, namesAndDefs

module.exports = (COP) ->
  [$root, $sys] = COP.lookupNames 'root', 'sys'

  props $root, name: [undefined, 'root']
  $sys.setProp $root, name: 'sys'

  method $root,
    toString: (data: {name}) ->
      if name
        "$" + name
      else
        "##{id.toString()}"

  method $sys,
    create: (stack) ->
      [parents] = stack.args
      o = COP.create parents
      COP.return stack, o

    addMethod: (stack) ->
      [obj, name, code] = stack.args
      COP.addMethod obj, name, code
      COP.return stack
