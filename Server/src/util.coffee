loadSettings = () ->
  settings = require './settings'
  try
    localsettings = require './localsettings'
  catch e
    localsettings = {}
  for own k, v of localsettings
    settings[k] = v
  settings