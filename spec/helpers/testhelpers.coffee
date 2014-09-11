CSON = require 'season'
path = require 'path'

using = (filename, func) ->
  csonData = CSON.readFileSync(path.resolve(__dirname, filename))
  for item in csonData
    do (item) ->
      func(item)

module.exports.using = using
