###
  Defines function for creating a rule from given condition patterns. Describes Rule object

  getParamTypeSwitcher(param) --> Different types
    param --> string describing parameter type
  returns an instance of the type described by the parameter

  getParamType(param) --> Different types
    param --> a string, function or an empty array
  returns an instance of the type of param

  parsePattern(pattern) --> List
    pattern --> list describing a condition in rule
  returns a list of pattern objects for each condition in pattern parameter

  Rule --> defines a Rule object
    constructor : set name, options, conditions and callback function of the rule
    fire : calls the callback function

  createRule(name, options, conditions, cb) --> Rule Object
    name --> name of the rule
    options --> ???
    conditions --> ???
    cb ---> callback function to fire
  returns a list of Rule objects for each condition
###

"use strict"

extd = require('./extended')
isArray = extd.isArray
Promise = extd.Promise
declare = extd.declare
parser = require('./parser')
pattern = require('./pattern')
ObjectPattern = pattern.ObjectPattern
NotPattern = pattern.NotPattern
CompositePattern = pattern.CompositePattern

#Converted code from switcher() to coffeescript switch statements

getParamTypeSwitcher = (param) ->
  switch param
    when "string" then return String
    when "date" then return Date
    when "array" then return Array
    when "boolean" then return Boolean
    when "regexp" then return RegExp
    when "number" then return Number
    when "object" then return Object
    when "hash" then return Object
    else throw new TypeError("Invalid parameter type #{param}")

# getParamType = (param) ->
#   switch param
#     when extd.isString(param) then getParamTypeSwitcher(param.toLowerCase())
#     when extd.isFunction(param) then return param
#     when extd.deepEqual(param, []) then return Array
#     else throw new Error("Invalid parameter type #{param}")
getParamType = extd
  .switcher()
  .isString( (param) -> return getParamTypeSwitcher(param.toLowerCase)
  )
  .isFunction( (func) -> return func
  )
  .deepEqual([], -> return Array
  )
  .def((param) -> throw new Error("Invalid parameter type #{param}")
  )
  .switcher()

parsePattern = (pattern) ->
  switch pattern
    when extd(pattern).containsAt("or", 0)
      pattern.shift() 
      extd(pattern).map( (cond) ->
        cond.scope = pattern.scope
        parsePattern(cond)
      ).flatten().value()
    when extd(pattern).contains("not", 0)
      pattern.shift()
      [ new NotPattern(
        getParamType(pattern[0]),
        pattern[1] or "m",
        parser.parseConstraint(pattern[2] or "true"),
        pattern[3] or {},
        {scope : pattern.scope, pattern: pattern[2]}
      )]
    else
      [ new ObjectPattern(
        getParamType(pattern[0]),
        pattern[1] or "m",
        parser.parseConstraint(pattern[2] or "true"),
        pattern[3] or {},
        {scope: pattern.scope, pattern: pattern[2]}
      )]
      
Rule = declare(
  instance : 
    constructor : (name, options, pattern, cb) ->
      @name = name
      @pattern = pattern
      @cb = cb
      if options.agendaGroup
        @agendaGroup = options.agendaGroup
        @autoFocus = (if extd.isBoolean(options.autoFocus) then options.autoFocus else false)
      @priority = options.priority or options.salience or 0

    fire : (flow, match) ->
      ret = new Promise()
      cb = @cb
      try
        if cb.length is 3 then cb.call(flow, match.factHash, flow, ret.classic) else cb.call(flow, match.factHash, flow)
      catch e
        ret.errback(e)
      return ret 
)

createRule = (name, options, conditions, cb) ->
  if extd.isArray(options)
    cb = conditions
    conditions = options
  else 
    options = options or {}           # can be replaced by default value
  isRules = extd.every(conditions, (cond) -> isArray(cond))
  if isRules and conditions.length is 1
    conditions = conditions[0]
    isRules = false
  rules = []
  scope = options.scope or {}
  conditions.scope = scope
  if isRules
    patterns = []
    _mergePatterns = (patt, i) ->
      if not patterns[i]                # Code can be replaced with more compact and better code
        patterns[i] = (if i is 0 then [] else patterns[i - 1].slice() )
        if i isnt 0 then patterns[i].pop()
        patterns[i].push(patt)
      else
        extd(patterns).forEach((p) -> p.push(patt))

    for condition in conditions
      condition.scope = scope
      extd.forEach(parsePattern(condition), _mergePatterns)        ##
    rules = extd.map(patterns, (patts) ->
      compPat = null
      i = 0
      while i < patts.length
        if compPat is null
          compPat = new CompositePattern(patts[i++], patts[i])
        else
          compPat = new CompositePattern(compPat, patts[i])
        i++
      new Rule(name, options, compPat, cb)
    )
  else
    rules = extd.map(parsePattern(conditions), (cond) -> new Rule(name, options, cond, cb))
  return rules

exports.createRule = createRule
