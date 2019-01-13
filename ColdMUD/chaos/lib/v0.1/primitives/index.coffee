comment = '''
  I define words which cannot be defined in terms of other Chaos words.

  The most important are:
    - The word for beginning a block of JavaScript or CoffeeScript code
    - maybe some others? haha

'''

cs = require 'coffeescript'

Dictionary = require './dictionary'
{ range }  = require '../util'

module.exports = (machine) ->
  BEGIN_BLOCK = machine.symbol 'BEGIN_BLOCK'

  (dict = new Dictionary)
    .define
      blockLevel: 0
      immediateFlag: false

      DEF:     -> value = @pop; @D.define [@pop]: value

      DUP:     -> @push  @top
      RDUP:    -> @rpush @rtop

      DROP:    -> @pop
      RDROP:   -> @rpop

      '>RS':   -> @rpush @pop
      '<RS':   -> @push @rpop

      DICT:    -> @push @D
      STACK:   -> @push @S
      RSTACK:  -> @push @R
      ERRORS:  -> @push @E
      SYMBOLS: -> @push @S

      '+':     -> @push @pop + @pop
      '-':     -> @push @pop - @pop
      '*':     -> @push @pop * @pop
      '/':     -> d = @pop; @push @pop / d
      '%':     -> @push @pop % @pop

      '/*':    ->
        [d, n] = [@pop, @pop]

        # Algorithem from Wikipedia
        unless d and 'number' is typeof d
          throw new @E.DivideByZero

        unless n and 'number' is typeof n
          @push 0
          return

        negative =
        switch
          when n < 0 and d > 0 then n = -n
          when n > 0 and d < 0 then d = -d

        q = r = 0

        for i from range (Math.floor Math.log2(n) - 1), 0
          r = r << 1
          r = r + n & (1 << i)

          if r >= d
            r -= d
            q += 1 << i

        q = -q if negative

        @push q
        @push r

      exec: -> @_exec @pop

      '!': ->
        unless (slot = @pop) instanceof ChaosSlot
          throw new @E.NotASlot

        value = @pop

        slot.set value

      '@': ->
        unless (slot = @pop) instanceof ChaosSlot
          throw new @E.NotASlot

        @push slot.get

      '.': ->

module.exports.comment = comment
