"use strict"

extd = require('./extended')
fs = require('fs')
path = require('path')
bind = extd.bind
forEach = extd.forEach
declare = extd.declare
Promise = extd.Promise
EventEmitter = require('events').EventEmitter
rule = require('./rule')
wm = require('./workingMemory')
WorkingMemory = wm.WorkingMemory
InitialFact = require('./pattern').InitialFact
Fact = wm.Fact
compile = require('./compile')
AgendaTree = require('./agenda')
Context = require('./context')

nools = {}

flows = {}

FlowContainer = declare(
  instance : 
    constructor : (name, cb) ->
      @env = null
      @name = name
      @cb = cb
      @__rules = []
      @__defined = {}
      @__wmAltered = false
      @workingMemory = new WorkingMemory()
      cb.call(this, this) if cb
      if not flows.hasOwnProperty(name)
        flows[name] = this
      else
        throw new Error("Flow with #{name} already defined")

    assert : (fact) ->
      @__wmAltered = true
      @__factHelper(fact, true)
      return fact

    retract : (fact) ->
      @__wmAltered = true
      @__factHelper(fact, false)
      return fact

    modify : (fact, cb) ->
      f = @retract(fact)
      cb.call(fact, fact) if typeof cb is "function"
      return @assert(f)

    makeConstraintsList : (ruleObj, patternNode) ->
      if patternNode.hasOwnProperty("leftPattern")
        @makeConstraintsList(ruleObj, patternNode.leftPattern)
      if patternNode.hasOwnProperty("rightPattern")
        @makeConstraintsList(ruleObj, patternNode.rightPattern)
      if patternNode.hasOwnProperty("constraints")
        ruleObj.constraintsList.push(patternNode.constraints)

    match : (cb) -> 
      for dRule in @__rules
        dRule.satisfyingFacts = []
        dRule.constraintsList = []
        @makeConstraintsList(dRule, dRule.pattern)

      for dRule in @__rules
        for constraints in dRule.constraintsList
          csFacts = []
          for fact in @workingMemory.facts 
            if @satisfies(constraints, fact)
              csFacts.push(fact)
          dRule.satisfyingFacts.push(csFacts)

      @__rules.sort((r1, r2) -> 
        return r1.priority - r2.priority
      )

      for dRule in @__rules
        if @checkFire(dRule)
          context = new Context(dRule.satisfyingFacts[0][0])
          context.set(dRule.constraintsList[0][0].alias, dRule.satisfyingFacts[0][0].object)
          for satisfyingFacts, i in dRule.satisfyingFacts 
            if i isnt 0
              c = new Context(satisfyingFacts[0])
              context.match = context.match.merge(c.match)
              context.set(dRule.constraintsList[i][0].alias, satisfyingFacts[0].object)
          dRule.fire(this, context.match)



    checkFire : (r) ->
      if r.satisfyingFacts.length is 0
        return false
      for satisfyingFacts in r.satisfyingFacts
        if satisfyingFacts.length is 0
          return false
      return true

    satisfies : (constraints, fact) ->
      for constraint in constraints
        switch constraint.type 
          when "object"
            if not constraint.assert(fact.object)
              return false
          when "equality"
            context = new Context(fact)
            context.set(constraint.alias, context.fact.object)
            if not constraint.assert(context.factHash)
              return false
      return true

    __factHelper : (object, assert) ->
      f = new Fact(object)
      f = (if assert then @__assertFact(f) else @__retractFact(f))

    __assertFact : (fact) ->
      wmFact = @workingMemory.assertFact(fact)
      return wmFact

    __retractFact : (fact) ->
      wmFact = @workingMemory.retractFact(fact)
      return wmFact

    dispose : () ->
      @workingMemory.dispose()

    getDefined : (name) ->
      ret = @__defined[name.toLowerCase()]
      throw new Error("#{name} flow class is not defined") if not ret
      return ret

    addDefined : (name, cls) ->
      @__defined[name.toLowerCase()] = cls
      return cls

    rule : ->
      @__rules = @__rules.concat(rule.createRule.apply(rule, arguments))
      return this

    getSession : ->
      @assert(new InitialFact())
      for argument in arguments
        @assert(argument)
      return this

    containsRule : (name) -> extd.some(@__rules, (rule) -> return rule.name is name)
).as(nools, "Flow")

isNoolsFile = (file) -> (/.nools$/).test(file)

parse = (source) ->
  if isNoolsFile(source)
    ret = compile.parse(fs.readFileSync(source, "utf-8"))
  else
    ret = compile.parse(source)
  return ret

nools.getFlow = (name) -> return flows[name]

nools.deleteFlow = (name) ->
  if extd.instanceOf(name, FlowContainer)
    name = name.name
  delete flows[name]
  return nools

nools.flow = (name, cb) -> return new FlowContainer(name, cb)

nools.compile = (file, options, cb) ->
  if extd.isFunction(options)
    cb = options
    options = {}
  else
    options or= {}
    cb = null
  if extd.isString(file)
    options.name = options.name or (if (isNoolsFile(file)) then path.basename(file, path.extname(file)) else null)
    file = parse(file)
  throw new Error("Name required when compiling nools source") if not options.name

  return compile.compile(file, options, cb, FlowContainer)

nools.parse = parse

module.exports = nools
