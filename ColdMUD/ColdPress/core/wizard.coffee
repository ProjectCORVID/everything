
objects wiz:
  parents: [$root]
  props:
    commands:
      create:
        subj: 'name'
        optional:
          prep: 'from'
          obj: ''
      destroy: {}
      move:    {}
      take:    {}
      drop:    {}
  methods:
    receiveCommand: (line) ->

module.exports = (COP) ->
  [$root, $sys] = COP.lookupNames 'root', 'sys'
  $wizard = COP.create $root
