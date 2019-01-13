Object.assign module.exports,
  listToString: (items, opts = {}) ->
    { sep         = ','
      conjunction = 'and'
      oxfordComma = false
      space       = ' '
    } = opts

    switch
      when items.length > 2
        s = items[..-2].join(sep + space)

        s += sep if oxfordComma

        s += space + conjunction + space + items[-1..][0]

      when items.length is 2
        s = items.join space + conjunction + space

      else
        s = items[0]


