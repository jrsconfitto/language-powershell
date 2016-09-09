path = require 'path'
fs = require 'fs'

describe "PowerShell grammar", ->

  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-powershell")

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.powershell')

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.powershell"
