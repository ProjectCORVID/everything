
Create an entire object library based on the features of the standard
SmallTalk libraries.

- inspection isn't just possible, it's fun
- everything is a messae
 - use class.new instead of new class
- almost everything has a category

# How we differ

- Use ColdMUD initialization pattern
 - Invoke 'init' as defined on each class of an instance, starting from the root
- Since we're not using SmallTalk syntax
 - operators are the same as they are in JavaScript/CoffeeScript

# Notes

Class isa ClassDescription isa Behavior isa Object isa ProtoObject isa #nil

- We'll have to do some funky stuff to make Object and Function do what we want.
  - Assigning to global.Object does not change the behavior of object literal syntax.
