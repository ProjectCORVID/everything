# Forth/Lisp syntax on top of NodeJS

Since starting this I've come to understand what I'm actually doing is
re-inventing PostScript, but I don't care, I'm doing it anyway.

# To do

- Clarify that symbol syntax helps with "use vs reference" problems

```coffee

# Normal:

Object.getOwnPropertyDescriptor object, propertyName

# Improved

Object.getOwnPropertyDescriptor ''object.propertyName

```

- Tests
- Make it work

# Differences from Forth

## Syntax

It's more like PostScript, but with no attempt at compatibility with either.
HA!

Brackets escape code, and their compilation behavior is to increase/decrease
escape level. Since, as in Lisp, blocks are just lists of values, we can do
all the cool Lisp macro tricks the same way it does, by performing
transformations on blocks, or constructing them dynamically.

```chaos

'addArg { ( value argsDict argInfo -- block )
  dup 'type . @
  4 pick
}

( Makes a word which makes an object described by argList )
'defArgs {  ( arglist -- block )
  { Dictionary 'create ->
    addArg
  }
  'push -> (add argList to block under construction
  { 'forEach -> } swap
  'concat ->
}
'defArgs def

```

# Files

- v0.1
 - data       : Classes for Chaos data types
 - interpret  : Chaos code for converting strings into literals and Chaos words
 - primitives : words which logically cannot be self-hosted
 - machine    : stacks, has a dictionary populated with primitives
  - To use it from node repl, invoke machine.exec, push, pop
- v0.2
 - minimal    : minimum words to make development practical
 - terminal   : adds words to drive a tty
 - command    : switches, repl, libs, etc
- v0.3
 - system     : wraps non-chaos modules
- v0.4
 - workspace  : persistent 'session', like SmallTalk
- v0.5

# On primitives

It seems in some ivory towers there are rumblings of the possibility of
implementing a 'usable' language in terms of N primitives. N seems to start
around 2 and go up from there based on what the language designer considers
reasonable. Lisp was originally described in terms of 7 primitives. Some Forth
implementations identify ~30 words as necessary to provide sufficient hardware
abstraction and adequate performance.

## Chaos Primitives

name    | signature             | notes
--------|-----------------------|------
DEF     | name       -- slot    | Creates a word
EXEC    | op         -- ...     | Invokes the object on top of the stack
!       | value slot --         | Store a value in a slot
@       |       slot -- value   | Query a slot
.       | name  slot -- slot    | Lookup a slot in a dictionary on the stack

