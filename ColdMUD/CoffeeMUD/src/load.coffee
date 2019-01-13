
# TODO: Migrate this into $sys

fs   = require 'fs'
path = require 'path'

notDotFile = (entry) -> entry[0] isnt '.'

examineEntry = (entry) ->
  fullPath  = path.resolve fsPath, entry
  stat      = fs.statSync fullPath
  basename  = path.basename entry, '.coffee'
  {fullPath, stat, basename}

# *.coffee before */*
filesFirstThenAlphabetical = (a, b) ->
  if a.isDirectory() is b.isDirectory()
    return (if a < b then -1 else 1)

  if b.isDirectory()
    -1
  else
     1

loadDir = (fsPath) ->
  o = {}
  entries =
    fs.readdirSync fsPath
      .filter notDotFile
      .map examineEntry
      .sort filesFirstThenAlphabetical

  for {fullPath, basename} in entries
    load fullPath, basename, o

  o

load = (fsPath, name, target) ->
  target[name] ?= {}

  Object.assign target[name],
    if (stat = fs.statSync fsPath).isDirectory()
      loadDir fsPath
    else
      require fsPath

module.exports = {loadDir, load}
