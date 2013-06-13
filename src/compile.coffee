###

  Defines functions for parsing actions and for creating rules, functions and defined objects

  parseAction(action, identifiers, defined, scope) --> Function
    action --> string containing the action code
    identifiers --> a list of identifiers for declaring variables used in action
    defined --> ??
    scope --> ??
  returns a function which when executed, executes the code in the action string
  
  __resolveRule(rule, identifiers, conditions, defined, name) --> Nothing
    rule --> List representing a rule constraint
    identifiers --> a list to populate with identifiers defined in rule constraint
    conditions --> a nested list to populate with rule constraints
    defined --> ???
    name --> ???
  return Nothing

  createRuleFromObject(obj, defined, scope) --> Rule Object
    obj --> An object of ??? type containing rule name, scope, constraints and action
    defined --> ???
    scope --> ???
  returns a Rule object representing obj parameter

  createFunction(body, defined, scope, scopeNames, definedNames) --> Function
    body --> string containing code of function
    defined --> ???
    scope --> ???
    scopeNames --> ???
    definedNames --> ???
  returns a function which executes the code written in the string

  _createDefined(options) --> Hash type object for class
    options --> a string or hash object containing definitions in define block
  returns a hash type object which describes a class, containing a constructor and properties mentioned in hash object

  createDefined(options) --> calls _createDefined with options.properties
    options --> a hash representing defined object
  
  parse(src) --> 
    src --> string containing DSL code

  compile(flowObj, options, cb, Container) --> Container object
    flowObj --> ???
    options --> ???
    cb --> ??? most probably a callback function
    Container --> ???
    returns an instance of Container object
  

###

do ->
  "use strict"
  extd = require('./extended')
  parser = require('./parser')
  constraintMatcher = require('./constraintMatcher')
  indexOf = extd.indexOf
  forEach = extd.forEach
  map = extd.map
  removeDuplicates = extd.removeDuplicates
  keys = extd.hash.keys
  merge = extd.merge
  isString = extd.isString
  bind = extd.bind
  rules = require('./rule')

  modifiers = ["assert", "modify", "retract", "emit", "halt", "focus"]

  parseAction = (action, identifiers, defined, scope) ->
    declares = []
    declares.push("var #{i} = facts.#{i};") for i in identifiers when action.indexOf(i) isnt -1
    declares.push("var #{i} = bind(flow, flow.#{i});") for i in modifiers when action.indexOf(i) isnt -1 
    declares.push("var #{i} = defined.#{i};") for i,j of defined when action.indexOf(i) isnt -1
    declares.push("var #{i} = scope.#{i};") for i,j of scope when action.indexOf(i) isnt -1
    params = ["facts", "flow"]
    params.push("next") if /next\(.*\)/.test(action)
    action = "with(this){" + declares.join("") + "#{action}}"
    try
      bind({defined : defined, scope : scope, bind : bind}, new Function(params.join(","), action))
    catch e
      throw new Error("Invalid action : #{action}\n#{e.message}")

  createRuleFromObject = do ->
    __resolveRule = (rule, identifiers, conditions, defined, name) ->
      condition = []
      definedClass = rule[0]
      alias = rule[1]
      constraint = rule[2]
      refs = rule[3]
      if extd.isHash(constraint)
        refs = constraint
        constraint = null
      if definedClass and !!(definedClass = defined[definedClass])
        condition.push(definedClass)
      else
        throw new Error("Invalid class #{rule[0]} for rule #{name}")
      condition.push(alias, constraint, refs)
      conditions.push(condition)
      identifiers.push(alias)
      if constraint
        identifiers.push(i) for i in constraintMatcher.getIdentifiers(parser.parseConstraint(constraint))
      if extd.isObject(refs)
        identifiers.push(ident) for j, ident of refs when ident not in identifiers
    (obj, defined, scope) ->
      name = obj.name
      throw new Error("Rule is empty") if extd.isEmpty(obj)
      options = obj.options or {}
      options.scope = scope
      constraints = obj.constraints or []
      constraints = ["true"] if not constraints.length
      action = obj.action
      throw new Error("No action was defined for rule #{name}") if extd.isUndefined(action)
      conditions = []
      identifiers = []
      for rule in constraints
        if rule.length
          r0 = rule[0]
          if r0 is "not"
            temp = []
            rule.shift()
            __resolveRule(rule, identifiers, temp, defined, name)
            cond = temp[0]
            cond.unshift(r0)
            conditions.push(cond)
          else if r0 is "or"
            conds = [r0]
            rule.shift()
            __resolveRule(cond, identifiers, conds, defined, name) for cond in rule
            conditions.push(conds)
          else
            __resolveRule(rule, identifiers, conditions, defined, name)
            identifiers = removeDuplicates(identifiers)
      return rules.createRule(name, options, conditions, parseAction(action, identifiers, defined, scope))

  createFunction = (body, defined, scope, scopeNames, definedNames) ->
    declares = []
    declares.push("var #{i} = defined.#{i};") for i in definedNames when body.indexOf(i) isnt -1
    declares.push("var #{i} = scope.#{i};") for i in scopeNames when body.indexOf(i) isnt -1
    body = ["((function(){", declares.join(""), "\n\treturn ", body, "\n})())"].join("")
    try
      eval(body)
    catch e
      throw new Error("Invalid action : #{body}\n#{e.message}")
  
  createDefined = do ->
    _createDefined = (options) ->
      options = (if isString(options) then (new Function("return #{options};"))() else options)
      ret = 0
      if options.hasOwnProperty("constructor") and typeof options.constructor is "function"
        ret = options.constructor
      else
        ret = (opts) ->
          opts or= {}
          (this[i] = opts[i]) for i of opts when i of options
          return this

      (ret.prototype[i] = options[i]) for i of options
      return ret

    (options) ->
      _createDefined(options.properties)

  exports.parse = (src) ->
    parser.parseRuleSet(src)

  exports.compile = (flowObj, options, cb, Container) ->
    if extd.isFunction(options)
      cb = options
      options = {}
    else
      options or= {}
      cb = null
    name = flowObj.name or options.name
    if not name then throw new Error("Name must be present in JSON or options")
    flow = new Container(name)
    defined = merge({Array: Array, String: String, Number: Number, Boolean: Boolean, RegExp: RegExp, Date: Date, Object: Object}, options.define or {})
    defined.Buffer = Buffer if typeof Buffer isnt "undefined"
    scope = merge({console: console}, options.scope)
    forEach(flowObj.define, (d) -> defined[d.name] = createDefined(d))        # try to replace by coffeescript forEach
    flow.addDefined(name, cls) for name, cls of defined
    scopeNames = extd(flowObj.scope).pluck("name").union(extd(scope).keys()).value()
    definedNames = map(keys(defined), (s) -> s)
    forEach(flowObj.scope, (s) -> scope[s.name] = createFunction(s.body, defined, scope, scopeNames, definedNames))   # try to replace by coffeescript forEach
    fRules = flowObj.rules
    if fRules.length
      flow.__rules = flow.__rules.concat(createRuleFromObject(rule, defined, scope)) for rule in fRules
    cb.call(flow, flow) if cb
    return flow

