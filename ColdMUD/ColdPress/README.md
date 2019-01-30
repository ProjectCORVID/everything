# ColdPress

ColdMUD in Coffee

- Single inheritance
- object methods are themselves
- none of the protections offered by ColdMUD are available
 - private data
 - access to sender()/caller()
 - etc

# Core Objects

- $root
 - $sys
  - .cobject
  - .core
  - .system
  - .setting
  - .world
 - $core
  - .concept
   - .noun: subject or object of a question or observation
   - .verb: dimension of a question or observation
    - .create
    - .destroy
    - .morph
    - .associate
    - .disassociate
   - .modifier: concept decorator such as 'any', 'some' or 'more'
   - .word: maps to concepts
   - .conjunction: 'and', 'or', etc
   - .definition: observation about a word or words
   - .dictionary: collection of definitions
   - .language: collection of dictionaries
  - .thing
   - .portal
   - .collection
   - .area
   - .actor
  - .observation: a statement about a world
   - .event: a canonical observation
   - .hypothetical
  - .world: a container of $vr stuff
  - .system
  - .setting
  - .world

# System Objects

## Nouns

- fundamental
  - person
  - connector
- locational
  - place
  - container
  - portal
  - wall
- descriptive/behavioral
  - material
