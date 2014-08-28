describe "PowerShell grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-powershell")

    runs ->
      grammar = atom.syntax.grammarForScopeName('source.powershell')

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.powershell"

  describe "comments", ->
    it "parses comments at the end of lines", ->
      {tokens} = grammar.tokenizeLine("$foo = 'bar' # a trailing comment")
      expect(tokens[0]).toEqual value: "$", scopes: ["source.powershell", "variable.other.powershell", "punctuation.variable.begin.powershell"]
      expect(tokens[1]).toEqual value: "foo", scopes: ["source.powershell", "variable.other.powershell"]
      expect(tokens[2]).toEqual value: " ", scopes: ["source.powershell"]
      expect(tokens[3]).toEqual value: "=", scopes: ["source.powershell", "keyword.operator.assignment.powershell"]
      expect(tokens[4]).toEqual value: " ", scopes: ["source.powershell"]
      expect(tokens[5]).toEqual value: "'", scopes: ["source.powershell", "string.quoted.single.single-line.powershell", "punctuation.definition.string.begin.powershell"]
      expect(tokens[6]).toEqual value: "bar", scopes: ["source.powershell", "string.quoted.single.single-line.powershell"]
      expect(tokens[7]).toEqual value: "'", scopes: ["source.powershell", "string.quoted.single.single-line.powershell", "punctuation.definition.string.end.powershell"]
      expect(tokens[8]).toEqual value: " # a trailing comment", scopes: ["source.powershell", "comment.line.number-sign.powershell"]

    it "parses comments at the beginning of lines", ->
      {tokens} = grammar.tokenizeLine("# a leading comment")
      expect(tokens[0]).toEqual value: "# a leading comment", scopes: ["source.powershell", "comment.line.number-sign.powershell"]

  describe "start of variable", ->
    it "parses the dollar sign at the beginning of a variable separately", ->
      {tokens} = grammar.tokenizeLine("$var")
      expect(tokens[0]).toEqual value: "$", scopes: ["source.powershell", "variable.other.powershell", "punctuation.variable.begin.powershell"]
      expect(tokens[1]).toEqual value: "var", scopes: ["source.powershell", "variable.other.powershell"]
