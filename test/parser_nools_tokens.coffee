assert = require('assert')
tokens = require('../bin/parser/nools/tokens.coffee')
should = require('should')

describe "Block Tokenizers tests - ", ->

  describe "/(block comments) tokenizer function", ->

    it "should remove block comment present at the starting of the string", ->
      assert.equal(tokens["/"]("/* lorem ipsum */ lorem ipsum"), " lorem ipsum")

    it "should do nothing to the string when no comments are present in the string", ->
      assert.equal(tokens["/"]("lorem ipsum lorem ipsum"), "lorem ipsum lorem ipsum")

  describe "define block tokenizer function", ->

    context = {}

    beforeEach( ->
      context = {define : []}
    )

    it "should throw an error if name of the define block is not present", ->
      nameNotPresent = "define {message:''}"
      (-> tokens["define"](nameNotPresent, context)).should.throw "Define block should have a name starting with an alphabet or dollar or underscore in:\n#{nameNotPresent}"

    it "should throw an error if name of the define block does not starts with an alphabet or dollar or underscore", ->
      wrongNameFormat = "define @Message {message:''}"
      (-> tokens["define"](wrongNameFormat, context)).should.throw "Define block should have a name starting with an alphabet or dollar or underscore in:\n#{wrongNameFormat}"

    it "should throw an error if name of the define block is not followed by an opening curly brace", ->
      bracketErr1 = "define Message message:''}"
      (-> tokens["define"](bracketErr1, context)).should.throw "Unexpected token \"m\" while beginning Define block (after the name of define block) of 'Define block Message'. Define block should have an opening curly bracket '{' after the name of define block"

    it "should throw an error if no matching closing curly bracket is found", ->
      bracketErr2 = "define Message { message:''"
      (-> tokens["define"](bracketErr2, context)).should.throw "No closing curly bracket '}' found in define block while defining 'Message'. Code:\n#{bracketErr2}"

    describe "when proper parsing is done", ->
      correctDefine = "define Message {message:''} lorem ipsum lorem ipsum"
      it "should return a string with define block completely removed", ->
        assert.equal(tokens["define"](correctDefine, context), " lorem ipsum lorem ipsum")

      it "should update the context object with defined object", ->
        tokens["define"](correctDefine, context)
        assert.equal(context.define[0].name, "Message")
        assert.equal(context.define[0].properties, "({message:\'\'})")

  describe "global block tokenizer function", ->
    context = {}

    beforeEach( ->
      context = {scope : []}
    )

    it "should throw an error if name of the global variable is not present", ->
      nameNotPresent = "global = 5;"
      (-> tokens["global"](nameNotPresent, context)).should.throw "Global declarations should have a variable name starting with an alphabet or dollar or underscore in:\n#{nameNotPresent}"

    it "should throw an error if name of the global variable does not starts with an alphabet or dollar or underscore", ->
      wrongNameFormat = "global @variable = 5;"
      (-> tokens["global"](wrongNameFormat, context)).should.throw "Global declarations should have a variable name starting with an alphabet or dollar or underscore in:\n#{wrongNameFormat}"

    it "should throw an error if name of the global variable is not followed by an equals sign", ->
      tokenErr1 = "global x 5;"
      (-> tokens["global"](tokenErr1, context)).should.throw "Unexpected token \"5\" in global declaration (after the name of variable) of 'Global variable x'. Global declarations should have an equals sign '=' after the name of the variable"

    it "should throw an error if no matching closing curly bracket is found", ->
      tokenErr2 = "global x = 5"
      (-> tokens["global"](tokenErr2, context)).should.throw "No semicolon ';' found while declaring global variable 'x'. Code:\n#{tokenErr2}"

    describe "when proper parsing is done", ->
      correctDefine = "global x = 5; lorem ipsum lorem ipsum"
      it "should return a string with global declaration completely removed", ->
        assert.equal(tokens["global"](correctDefine, context), " lorem ipsum lorem ipsum")

      it "should update the context object with defined global variable", ->
        tokens["global"](correctDefine, context)
        assert.equal(context.scope[0].name, "x")
        assert.equal(context.scope[0].body, "5")

  describe "function block tokenizer function", ->
    context = {}

    beforeEach( ->
      context = {scope : []}
    )

    it "should throw an error if name of the function is not present", ->
      nameNotPresent = "function () { return true; }"
      (-> tokens["function"](nameNotPresent, context)).should.throw "Function declaration should have a function name starting with an alphabet or dollar or underscore in:\n#{nameNotPresent}"

    it "should throw an error if name of the function does not starts with an alphabet or dollar or underscore", ->
      wrongNameFormat = "function @f() {return true;}"
      (-> tokens["function"](wrongNameFormat, context)).should.throw "Function declaration should have a function name starting with an alphabet or dollar or underscore in:\n#{wrongNameFormat}"

    it "should throw an error if name of the function is not followed by an opening parentheses ", ->
      tokenErr1 = "function f  { return true ;}"
      (-> tokens["function"](tokenErr1, context)).should.throw "Unexpected token \"{\" in function declaration (after name of the function) of 'Function f'. Function declarations should have an opening parentheses '(' after the function name"

    it "should throw an error if no matching closing parentheses is found", ->
      tokenErr2 = "function f (arg1 { return true ;}"
      (-> tokens["function"](tokenErr2, context)).should.throw "No closing parentheses ')' found for arguments list of function 'f'. Code:\n#{tokenErr2}"
    
    it "should throw an error if no opening curly bracket is found after the closing parentheses", ->
      tokenErr3 = "function f (arg1)  return true ;}"
      (-> tokens["function"](tokenErr3, context)).should.throw "Unexpected token \"r\" in function declaration (after the closing parentheses of arguments list) of 'Function f'. Function declarations should have an opening curly bracket '{' after the closing parentheses of argument list"

    it "should throw an error if no closing curly bracket is found corresponding to the opening curly bracket", ->
      tokenErr4 = "function f (arg1)  {return true ;"
      (-> tokens["function"](tokenErr4, context)).should.throw "No closing curly bracket '}' found in function declaration of function 'f'. Code:\n#{tokenErr4}"

    describe "when proper parsing is done", ->
      correctDefine = "function f (arg1)  { {x = 1;} return true ;} lorem ipsum lorem ipsum"
      it "should return a string with function declaration completely removed", ->
        assert.equal(tokens["function"](correctDefine, context), " lorem ipsum lorem ipsum")

      it "should update the context object with defined function", ->
        tokens["function"](correctDefine, context)
        assert.equal(context.scope[0].name, "f")
        assert.equal(context.scope[0].body, "function(arg1){ {x = 1;} return true ;}")

  describe "rule block tokenizer function", ->
    context = {}
    parse = null

    beforeEach( ->
      context.rules = []
      parse = -> return true
    )

    it "should throw an error if name of the rule is not present", ->
      nameNotPresent = "rule {lorem ipsum}"
      (-> tokens["rule"](nameNotPresent, context, parse)).should.throw "Rule block should have a name starting with an alphabet or dollar or underscore or enclosed in single or double quotes\n#{nameNotPresent}"

    it "should throw an error if name of the rule does not starts with an alphabet or dollar or underscore or is not enclosed in single or double quotes", ->
      wrongNameFormat = "rule #first {lorem ipsum}"
      (-> tokens["rule"](wrongNameFormat, context, parse)).should.throw "Rule block should have a name starting with an alphabet or dollar or underscore or enclosed in single or double quotes\n#{wrongNameFormat}"

    it "should throw an error if name of the rule block starts with a single quote but doesn't ends with a single quote", ->
      wrongNameFormat2 = "rule 'first {lorem ipsum}"
      (-> tokens["rule"](wrongNameFormat2, context, parse)).should.throw "Name of the Rule block should start with a single quote should end with a single quote\n#{wrongNameFormat2}"

    it "should throw an error if name of the rule block starts with a double quote but doesn't ends with a double quote", ->
      wrongNameFormat3 = "rule \"first {lorem ipsum}"
      (-> tokens["rule"](wrongNameFormat3, context, parse)).should.throw "Name of the Rule block should start with a double quote should end with a double quote in rule\n#{wrongNameFormat3}"      

    it "should throw an error if name of the rule is not followed by an opening curly bracket", ->
      tokenErr1 = "rule r lorem ipsum}"
      (-> tokens["rule"]("rule r lorem ipsum}")).should.throw "Unexpected token \"l\" while beginning Rule block (after name of the rule) of 'Rule r'. Rule block should have an opening curly bracket '{' after name of the rule"

    it "should throw an error if no closing curly bracket is found corresponding to the opening curly bracket", ->
      tokenErr2 = "rule r {lorem ipsum"
      (-> tokens["rule"]("rule r {lorem ipsum")).should.throw "No closing curly bracket '}' found in Rule block of rule 'r'. Code:\n#{tokenErr2}"

    describe "when proper parsing is done", ->
      correctDefine = "rule r { when {} then {} } lorem ipsum lorem ipsum"
      it "should return a string with function declaration completely removed", ->
        assert.equal(tokens["rule"](correctDefine, context, parse), " lorem ipsum lorem ipsum")

#      it "should update the context object with defined function"   //tests similar to these are done in nool.parser.coffee

  
