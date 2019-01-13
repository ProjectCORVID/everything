# More CORVID research, sorta

Interactive Fiction is a fancy name for Choose Your Own Adventure stories.

- At any given moment the player has a menu of choices
- User interface discovery is not part of the game
- Usually choices are one-way paths
- There may be some choices which become variables which come in to play later
  - Player's choice of resource investment eventually changes future resource options

# Design

## Objects

- "VR"
  - World 
    - has Situations
    - has shared state, either static or dynamic
  - Situation (a page of the "book")
    - has a description generator
    - has a menu generator
    - one is marked as "start"
    - one or more are marked as "ends"
  - Menu (player's current choices)
  - Choice
    - Path from one Situation to another
    - Also may impact Results
  - Results (ongoing state)

- Interface
  - has a world, including current Situation and Results

## World definition language

By example:

```coffee
    module.exports = ({world, situation, menu, choice, result}) ->
      world
        title: 'Example Town'
      
      situation
        start:
          desc: """
            You finally made it! Example Town, USA! All your hard work and
            saving has paid off. A new chapter in your life is about to
            unfold.

            As your bus rolls through town on its way to the station you can
            see through the windows that this place matches the brouchures "to
            a tee." Or is it "tea?" You never were good at that kind of thing.
            
            Whatever.

            Example Town is small, quiet and quaint with no hint whatsoever of
            the sinister.
          """

          menu:
            menu.minimum andAlso:
```
