assert = require('assert')
parser = require('../src/parser/index.coffee')
should = require('should')

describe "Parsing functions interface functions", ->
  describe "parseConstraint function", ->
    it "should throw an error if expression is found to be invalid", ->
      invalidExpr = "x -= 2"
      (-> parser.parseConstraint(invalidExpr)).should.throw "Invalid expression '#{invalidExpr}'"

  # other tests are same as in parser_constraint_parser.coffee


# tests for parseRuleSet function are same as for parser_nools_nool.parser.coffee
