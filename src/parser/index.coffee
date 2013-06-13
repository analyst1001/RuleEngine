###
  Define functions for parsing rule bodies and expressions

  function parseConstraint(expression) --> List
    expression --> string expression to be parsed
  returns a nested list representing the string expression parsed by defined CFG

  function parseRuleSet(source) --> Hash
    source --> string containing rule definitions
  returns a hash of context parameters of rules defined in source string
###

do ->
  "use strict"
  constraintParser = require('./constraint/parser')
  noolParser = require('./nools/nool.parser')

  exports.parseConstraint = (expression) ->
    try
      constraintParser.parse(expression)
    catch e
      throw new Error("Invalid expression '#{expression}'")

  exports.parseRuleSet = (source) ->
    noolParser.parse(source)
    