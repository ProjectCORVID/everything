fs = require 'fs'

export class Core
  constructor: (@DB, fileOrDir) ->
    stat = fs.statSync fileOrDir

    if stat.isFile()
      @loadFile fileOrDir
    else if stat.isDirectory()
      @loadDir fileOrDir

  loadFile: (file) ->
