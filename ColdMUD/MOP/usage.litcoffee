
    { Model, Feature, Validator } = MOP = require 'mop'

    Feature 'Named',
      has:
        name:
          validator: Validator.string

      does:
        nameStr: -> @get 'name'

      initInstance: (info) ->
        if name = info.name
          @set 'name', name


    Model 'Person',
      has:
        personName: String

      does:
        Named:
          share: [ 'name': 'personName' ]

    Position = Model
      name: 'Position'

      has:
        role: String

    Team = Model
      name: 'Team'

      hasMany:
        Position

    Position.addBelongsTo team: Team

    Employee = Model
      extends: Person

      hasMany: Position

      does:
        TeamMember: {}

    robert = Person.create name: "Robert de Forest"

    someTeam = Team.create name: "Some Team"

    contibuter = Position.create
      team: someTeam
      role: "contributer"

    robert.as Employee, 'addPosition', contributer


