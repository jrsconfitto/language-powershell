class AutomaticVariable
  ignoreCase = true
  delimiter: "$"
  delimiterScopes: ["source.powershell","variable.language.powershell","punctuation.variable.begin.powershell"]
  expectedNameScopes: ["source.powershell","variable.language.powershell"]

  constructor: (@grammar) ->

  startsWith: (delimiter) ->
    @delimiter = delimiter
    this

  ignoreCase: ->
    @ignoreCase = true
    this

  dontIgnoreCase: ->
    @ignoreCase = false
    this

  execute: (name) ->
    input = @delimiter + name
    {tokens} = @grammar.tokenizeLine(input)
    expect(tokens[0]).toEqual value: @delimiter, scopes: @delimiterScopes
    expect(tokens[1]).toEqual value: name, scopes: @expectedNameScopes

  expectVariable: (name) ->
    this.execute(name)
    this.execute(name.toLowerCase()) if @ignoreCase?
    this.execute(name.toUpperCase()) if @ignoreCase?


module.exports.AutomaticVariable = AutomaticVariable
