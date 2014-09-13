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
      expect(tokens[8]).toEqual value: " ", scopes: ["source.powershell", "comment.line.number-sign.powershell"]
      expect(tokens[9]).toEqual value: "#", scopes: ["source.powershell", "comment.line.number-sign.powershell", "punctuation.definition.comment.powershell"]
      expect(tokens[10]).toEqual value: " a trailing comment", scopes: ["source.powershell", "comment.line.number-sign.powershell"]

    it "parses comments at the beginning of lines", ->
      {tokens} = grammar.tokenizeLine("# a leading comment")
      expect(tokens[0]).toEqual value: "#", scopes: ["source.powershell", "comment.line.number-sign.powershell", "punctuation.definition.comment.powershell"]
      expect(tokens[1]).toEqual value: " a leading comment", scopes: ["source.powershell", "comment.line.number-sign.powershell"]

  describe "start of variable", ->
    it "parses the dollar sign at the beginning of a variable separately", ->
      {tokens} = grammar.tokenizeLine("$var")
      expect(tokens[0]).toEqual value: "$", scopes: ["source.powershell", "variable.other.powershell", "punctuation.variable.begin.powershell"]
      expect(tokens[1]).toEqual value: "var", scopes: ["source.powershell", "variable.other.powershell"]

  describe "Double-quoted strings", ->
    describe "Highlight normal double-quoted string", ->
      tokens = null

      beforeEach ->
        {tokens} = grammar.tokenizeLine("\"Hi there! and welcome to 'string-making': 101.\"")

      it "should tag the opening double-quote", ->
        expect(tokens[0]).toEqual value: "\"", scopes: ["source.powershell", "string.quoted.double.single-line.powershell", "punctuation.definition.string.begin.powershell"]

      it "should tag content of the string", ->
        expect(tokens[1]).toEqual value: "Hi there! and welcome to 'string-making': 101.", scopes: ["source.powershell", "string.quoted.double.single-line.powershell"]

      it "should tag the closing double-quote", ->
        expect(tokens[2]).toEqual value: "\"", scopes: ["source.powershell", "string.quoted.double.single-line.powershell", "punctuation.definition.string.end.powershell"]

    describe "Highlight empty string", ->
      tokens = null

      beforeEach ->
        {tokens} = grammar.tokenizeLine("\"\"")

      it "should tag the opening double-quote", ->
        expect(tokens[0]).toEqual value: "\"", scopes: ["source.powershell", "string.quoted.double.single-line.powershell", "punctuation.definition.string.begin.powershell"]

      it "should tag the closing double-quote as empty string", ->
        expect(tokens[1]).toEqual value: "\"", scopes: ["source.powershell", "string.quoted.double.single-line.powershell", "punctuation.definition.string.end.powershell", "meta.empty-string.double.powershell"]

    describe "Highlight Powershell variables within the string", ->
      tokens = null

      beforeEach ->
        {tokens} = grammar.tokenizeLine("\"Hi there $name\"")

      it "should tag content", ->
        expect(tokens[1]).toEqual value: "Hi there ", scopes: ["source.powershell", "string.quoted.double.single-line.powershell"]

      it "should tag the beginning of variable names", ->
        expect(tokens[2]).toEqual value: "$", scopes: ["source.powershell", "string.quoted.double.single-line.powershell", "embedded.variable.other.powershell", "embedded.punctuation.variable.begin.powershell"]

      it "should tag variable names", ->
        expect(tokens[3]).toEqual value: "name", scopes: ["source.powershell", "string.quoted.double.single-line.powershell", "embedded.variable.other.powershell"]

  describe "Highlighting keywords", ->
    describe "Flow keywords", ->

      describe "If-else statements", ->
        tokens = null

        beforeEach ->
          {tokens} = grammar.tokenizeLine("if($answer.length -lt 10) { echo $answer } elseif($answer.length -lt 100) { echo \"You talk a lot\" } else { echo \"?\"}")

        it "should highlight 'if'", ->
          expect(tokens[0]).toEqual value: "if", scopes: ["source.powershell","keyword.control.flow.powershell"]

        it "should highlight 'elseif'", ->
          expect(tokens[18]).toEqual value: "elseif", scopes: ["source.powershell","keyword.control.flow.powershell"]

        it "should highlight 'else'", ->
          expect(tokens[37]).toEqual value: "else", scopes: ["source.powershell","keyword.control.flow.powershell"]

      describe "Do-until statements", ->
        tokens = null

        beforeEach ->
          {tokens} = grammar.tokenizeLine("do { echo $i; $i += 1 } until($i -gt 100)")

        it "should highlight 'do'", ->
          expect(tokens[0]).toEqual value: "do", scopes: ["source.powershell","keyword.control.flow.powershell"]
        it "should highlight 'until'", ->
          expect(tokens[14]).toEqual value: "until", scopes: ["source.powershell","keyword.control.flow.powershell"]

      describe "'For' statements", ->
        tokens = null

        beforeEach ->
          {tokens} = grammar.tokenizeLine("for($i=0;i<10;$i++) { echo $i }")

        it "should highlight 'for'", ->
          expect(tokens[0]).toEqual value: "for", scopes: ["source.powershell","keyword.control.flow.powershell"]

    describe "Highlighting logical operators", ->
      logicalOperators = [ "-and", "-or", "-xor", "-not", "!"]

      it "tokenizes logical operators", ->
        for operator in logicalOperators
          {tokens} = grammar.tokenizeLine operator
          expect(tokens[0]).toEqual value: operator, scopes: ["source.powershell","keyword.operator.logical.powershell"]

    describe "Highlighting bitwise operators", ->
      bitwiseOperators = [ "-bAnd", "-bOr", "-bXor", "-bNot", "-shl", "-sh" ]

      it "tokenizes bitwise operators", ->
        for operator in bitwiseOperators
          {tokens} = grammar.tokenizeLine operator
          expect(tokens[0]).toEqual value: operator, scopes: ["source.powershell","keyword.operator.bitwise.powershell"]

    describe "Highlighting comparison operators", ->
      comparisonOperators = [
        "-eq", "-ceq", "-ieq", "-lt", "-gt", "-le", "-ge", "-ne", "-notlike",
        "-like", "-match", "-notmatch", "-contains", "-notcontains", "-in",
        "-notin", "-replace"
      ]

      it "tokenizes comparison operators", ->
        for operator in comparisonOperators
          {tokens} = grammar.tokenizeLine operator
          expect(tokens[0]).toEqual value: operator, scopes: ["source.powershell","keyword.operator.comparison.powershell"]

  describe "Highlighting automatic variables", ->
    automaticVariables = [
      "$null", "$true", "$false", "$$", "$?", "$^", "$_",
      "$Args", "$ConsoleFileName", "$Error", "$Event", "$EventArgs",
      "$EventSubscriber", "$ExecutionContext", "$ForEach", "$Host", "$Home", "$Input",
      "$LastExitCode", "$Matches", "$MyInvocation", "$NestedPromptLevel", "$OFS",
      "$PID", "$Profile", "$PSBoundParameters", "$PSCmdlet", "$PSCommandPath",
      "$PSCulture", "$PSDebuggingContext", "$PSHome", "$PSItem", "$PSScriptRoot",
      "$PSSenderInfo", "$PSUICulture", "$PSVersionTable", "$Pwd", "$Sender",
      "$ShellID", "$StackTrace", "$This"
    ]

    it "tokenizes automatic language variables", ->
      for variable in automaticVariables
        {tokens} = grammar.tokenizeLine variable
        expect(tokens[0].value).toEqual "$"
        expect(tokens[0].scopes).toEqual ["source.powershell", "variable.language.powershell", "punctuation.variable.begin.powershell"]
        expect(tokens[1].value).toEqual variable.substr(1)
        expect(tokens[1].scopes).toEqual ["source.powershell", "variable.language.powershell"]

  describe "Highlight cmdlets", ->
    cmdlets = ["Get-ChildItem","_-_","underscores_are-not_a_problem"]

    it "tokenizes cmdlets", ->
      for cmdlet in cmdlets
        {tokens} = grammar.tokenizeLine cmdlet
        expect(tokens[0].value).toEqual cmdlet
        expect(tokens[0].scopes).toEqual ["source.powershell", "keyword.cmdlet.powershell"]

  describe "Highlighting escaped characters", ->
    escapedCharacters = [
      "`n", "`\"", "`\'", "`a", "`b", "`r", "`t", "`f", "`0", "`v", "--%", "``"
    ]

    it "tokenizes escaped characters", ->
      for character in escapedCharacters
        {tokens} = grammar.tokenizeLine character
        expect(tokens[0].value).toEqual character
        expect(tokens[0].scopes).toEqual ["source.powershell", "constant.character.escape.powershell"]
