###

  Defines functions for converting constraints lists into javascript code

  definedFuncs --> maps function names to functions, most of which are already defined in extended libraries
    indexOf --> defined in array-extended package
    
    now() --> Date
    returns a date object representing current date and time

    Date(y, m, d, h, min, s, ms) -> Date
      y --> number representing year
      m --> number representing month
      d --> number representing date
      h --> number representing hour
      min --> number representing minute
      s --> number representing second
      ms --> number representing millisecond
    returns a date object representing the date and time provided as arguments

    lengthOf(arr, length) --> Boolean
      arr --> an array object
      length --> an integer
    returns true if size of array is equal to the length parameter, otherwise returns false

    isTrue(val) --> Boolean
      val --> Boolean value
    returns true if val paramter is a boolean true, otherwise returns false
    
    isFalse(val) --> Boolean
      val --> Boolean value
    returns true if val parameter is a boolean false, otherwise returns false

    isNotNull(actual) --> Boolean
      actual --> any identifier
    returns true if the identifier value is not null, otherwise returns false

    dateCmp(c1, c2) --> uses compare function defined in date-extended package

    Functions defined in date-extended                       
      yearsFromNow            
      daysFromNow             
      monthsFromNow           
      hoursFromNow            
      minutesFromNow          
      secondsFromNow          
      yearsAgo                
      daysAgo                 
      monthsAgo               
      hoursAgo                
      minutesAgo              
      secondsAgo

    Functions defined in is-extended
      isArray
      isNumber
      isHash
      isObject
      isDate
      isBoolean
      isString
      isRegExp
      isNull
      isEmpty
      isUndefined
      isDefined
      isUndefinedOrNull
      isPromiseLike
      isFunction
      deepEqual             
  
  lang --> define functions for operations in the define CFG to map the list obtained from CFG to javascript code + some other helper functions
    equal(c1,c2) --> Boolean
      c1 --> List representing expression
      c2 --> List representing expression
    returns true if c1 and c2 represent the same expression, otherwise returns false

    getIdentifiers(rule) --> List
      rule --> List representing expressions in a rule
    returns a list of identifiers in the expressions

    toConstraints(rule, options) --> List
      rule --> List representing expressions in a rule
      options --> ???
    returns a list of Constraint objects

    parse(rule) --> string
      rule --> rule --> List representing expressions in a rule
    returns a string representing a javascript expression for the rule

    composite(lhs) --> string
      lhs --> List representing a composite expression
    returns a string representing a javascript expression for the composite expression

    and(lhs, rhs) --> string
      lhs --> left hand expression list of the and operator
      rhs --> right hand expression list of the and operator
    returns a string representing a javascript expression for the and expression

    or(lhs, rhs) --> string
      lhs --> left hand expression list of the or operator
      rhs --> right hand expression list of the or operator
    returns a string representing a javascript expression for the or expression

    prop(name, prop) --> string
      name --> list representing the name expression of object
      prop --> list representing the property 
    returns a string representing a javascript expression for the property

    unminus(lhs) --> string
      lhs --> list representing the expression on which unary minus is applied
    returns a string expression representing the javascript expression for the unary minus operation

    plus(lhs, rhs) --> string
      lhs --> left hand expression list of the plus operator
      rhs --> right hand expression list of the plus operator
    returns a string representing a javascript expression for the plus expression

    minus(lhs, rhs) --> string
      lhs --> left hand expression list of the minus operator
      rhs --> right hand expression list of the minus operator
    returns a string representing a javascript expression for the minus expression

    mult(lhs, rhs) --> string
      lhs --> left hand expression list of the multiplication operator
      rhs --> right hand expression list of the multiplication operator
    returns a string representing a javascript expression for the multiplication expression

    div(lhs, rhs) --> string
      lhs --> left hand expression list of the division operator
      rhs --> right hand expression list of the division operator
    returns a string representing a javascript expression for the division expression

    mod(lhs, rhs) --> string
      lhs --> left hand expression list of the modulus operator
      rhs --> right hand expression list of the modulus operator
    returns a string representing a javascript expression for the modulus expression

    lt(lhs, rhs) --> string
      lhs --> left hand expression list of the less than operator
      rhs --> right hand expression list of the less than operator
    returns a string representing a javascript expression for the less than expression

    gt(lhs, rhs) --> string
      lhs --> left hand expression list of the greater than operator
      rhs --> right hand expression list of the greater than operator
    returns a string representing a javascript expression for the greater than expression

    lte(lhs, rhs) --> string
      lhs --> left hand expression list of the less than and equal operator
      rhs --> right hand expression list of the less than and equal operator
    returns a string representing a javascript expression for the less than and equal expression

    gte(lhs, rhs) --> string
      lhs --> left hand expression list of the greater than and equal operator
      rhs --> right hand expression list of the greater than and equal operator
    returns a string representing a javascript expression for the greater than and equal expression

    like(lhs, rhs) --> string
      lhs --> left hand expression list of the like operator
      rhs --> right hand expression list of the like operator(normally a regexp)
    returns a string representing a javascript expression for the like expression

    notLike(lhs, rhs) --> string
      lhs --> left hand expression list of the notLike operator
      rhs --> right hand expression list of the notLike operator(normally a regexp)
    returns a string representing a javascript expression for the notLike expression

    eq(lhs, rhs) --> string
      lhs --> left hand expression list of the equality operator
      rhs --> right hand expression list of the equality operator
    returns a string representing a javascript expression for the equality expression

    neq(lhs, rhs) --> string
      lhs --> left hand expression list of the inequality operator
      rhs --> right hand expression list of the inequality operator
    returns a string representing a javascript expression for the inequality expression

    in(lhs, rhs) --> string
      lhs --> left hand expression list of the in operator
      rhs --> right hand expression list of the in operator(normally an array)
    returns a string representing a javascript expression for the in expression

    notIn(lhs, rhs) --> string
      lhs --> left hand expression list of the notIn operator
      rhs --> right hand expression list of the notIn operator(normally an array)
    returns a string representing a javascript expression for the notIn expression

    arguments(lhs, rhs) --> string
      lhs --> list representing all but last arguments
      rhs --> list representing the last argument
    returns a string representing a javascript expression for the arguments

    array(lhs) --> string
      lhs --> list representing array elements
    returns a string representing a javascript expression for the array

    function(lhs, rhs) --> string
      lhs --> list representing the name of the function
      rhs --> list representing arguments to the function
    returns a string representing a javascript expression for the function declaration

    string(lhs) --> string
      lhs --> string
    returns single quoted lhs

    number(lhs) --> number
      lhs --> number
    returns number lhs

    boolean(lhs) --> boolean
      lhs --> boolean value
    returns boolean lhs

    regexp(lhs) --> regexp object
      lhs --> regular expression object
    returns regular expression object lhs

    identifier(lhs) --> string
      lhs --> string
    returns string lhs

    null() --> Null object
    returns a null object

    toJs(rule, scope) --> Function
      rule --> a nested list representing rule constraints
      scope  --> ???
    converts the rule list into javascript code and returns a function which given two dictionaries, executes the javascript code
    
    getMatcher(rule, scope) --> another alias for toJs

    toConstraints(constraint, options) --> another alias for lang.toConstraints
    
    equal(c1, c2) --> another alias for lang.equal

    getIdentifiers(constraint) --> another alias for lang.getIdentifiers


###

"use strict"

extd = require('./extended')
isArray = extd.isArray
forEach = extd.forEach
some = extd.some
map = extd.map
indexOf = extd.indexOf
isNumber = extd.isNumber
removeDups = extd.removeDuplicates
atoms = require('./constraint')

definedFuncs = 
  indexOf : extd.indexOf
  now : -> new Date()
  Date : (y, m, d, h, min, s, ms) ->
    date = new Date()
    date.setYear(y) if isNumber(y)
    date.setMonth(m) if isNumber(m)
    date.setDate(d) if isNumber(d)
    date.setHours(h) if isNumber(h)
    date.setMinutes(min) if isNumber(min)
    date.setSeconds(s) if isNumber(s)
    date.setMilliseconds(ms) if isNumber(ms)
    return date
  lengthOf : (arr, length) -> arr.length is length
  isTrue : (val) -> val is true
  isFalse : (val) -> val is false
  isNotNull : (actual) -> actual isnt null 
  dateCmp : (d1, d2) -> extd.compare(d1, d2)

for k in ["years", "days", "months", "hours", "minutes", "seconds"]
  definedFuncs[k + "FromNow"] = extd[k + "FromNow"]
  definedFuncs[k + "Ago"] = extd[k + "Ago"]

definedFuncs[k] = -> extd[k].apply(extd, arguments) for k in ["isArray", "isNumber", "isHash", "isObject", "isDate", "isBoolean", "isString", "isRegExp", "isNull", "isEmpty",
    "isUndefined", "isDefined", "isUndefinedOrNull", "isPromiseLike", "isFunction", "deepEqual"]

lang =  
  equal: (c1, c2) ->
    ret = false
    if c1 is c2
      ret = true
    else
      if c1[2] is c2[2]
        if c1[2] in ["string", "number", "boolean", "regexp", "identifier", "null"]
          ret = c1[0] is c2[0]
        else if c1[2] is "uminus"
          ret = @equal(c1[0], c2[0])
        else
          ret = @equal(c1[0], c2[0]) and @equal(c1[1], c2[1])
    return ret

  getIdentifiers : (rule) ->
    ret = []
    rule2 = rule[2]

    if rule2 is "identifier"
      return [rule[0]]
    else if rule2 is "function"
      ret.push(rule[0])
      ret = ret.concat(@getIdentifiers(rule[1]))
    else if rule2 not in ["string", "number", "boolean", "regexp", "uminus"]
      if rule2 is "prop"
        ret = ret.concat(@getIdentifiers(rule[0]))
        if rule[1]
          propChain = rule[1]
          while isArray(propChain)                                  # find a case where while loop is required
            if propChain[2] is "function"
              ret = ret.concat(@getIdentifiers(propChain[1]))       # why only propChain[1](function arguments) why not propChain[0](function name)
              break
            else
              propChain = propChain[1]
      else
        ret = ret.concat(@getIdentifiers(rule[0])) if rule[0]
        ret = ret.concat(@getIdentifiers(rule[1])) if rule[1]
    removeDups(ret)
    return ret

  toConstraints : (rule, options) ->
    ret = []
    alias = options.alias
    scope = options.scope or {}
    rule2 = rule[2]

    if rule2 is "and"
      ret = ret.concat(@toConstraints(rule[0], options)).concat(@toConstraints(rule[1], options))
    else if rule2 in ["composite", "or", "lt", "gt", "lte", "gte", "like", "notLike", "eq", "neq", "in", "notIn", "function"]
      if some(@getIdentifiers(rule), (i) -> i isnt alias and i not of definedFuncs and i not of scope)
        ret.push(new atoms.ReferenceConstraint(rule, options)) 
      else
        ret.push(new atoms.EqualityConstraint(rule, options))
    return ret

  parse : (rule) -> @[rule[2]](rule[0], rule[1])

  composite : (lhs) -> @parse(lhs)

  and : (lhs, rhs) -> [@parse(lhs), "&&", @parse(rhs)].join(" ")

  or : (lhs, rhs) -> [@parse(lhs), "||", @parse(rhs)].join(" ")

  prop : (name, prop) -> 
    if prop[2] in "function"
      [@parse(name), @parse(prop)].join(".")
    else
      [@parse(name), "['", @parse(prop), "']"].join("")

  unminus : (lhs) -> -1 * @parse(lhs)

  plus : (lhs, rhs) -> [@parse(lhs), "+", @parse(rhs)].join(" ")

  minus : (lhs, rhs) -> [@parse(lhs), "-", @parse(rhs)].join(" ")

  mult : (lhs, rhs) -> [@parse(lhs), "*", @parse(rhs)].join(" ")

  div : (lhs, rhs) -> [@parse(lhs), "/", @parse(rhs)].join(" ")

  mod : (lhs, rhs) -> [@parse(lhs), "%", @parse(rhs)].join(" ")

  lt : (lhs, rhs) -> [@parse(lhs), "<", @parse(rhs)].join(" ")

  gt : (lhs, rhs) -> [@parse(lhs), ">", @parse(rhs)].join(" ")

  lte : (lhs, rhs) -> [@parse(lhs), "<=", @parse(rhs)].join(" ")

  gte : (lhs, rhs) -> [@parse(lhs), ">=", @parse(rhs)].join(" ")

  like : (lhs, rhs) -> [@parse(rhs), ".test(", @parse(lhs), ")"].join("")

  notLike : (lhs, rhs) -> ["!", @parse(rhs), ".test(", @parse(rhs), ")"].join("")

  eq : (lhs, rhs) -> [@parse(lhs), "===", @parse(rhs)].join(" ")

  neq : (lhs, rhs) -> [@parse(lhs), "!==", @parse(rhs)].join(" ")

  in : (lhs, rhs) -> ["(indexOf(", @parse(rhs), ",", @parse(lhs), ")) !== -1"].join("")       # added !== for type safety

  notIn : (lhs, rhs) -> ["(indexOf(", @parse(rhs), ",", @parse(lhs), ")) === -1"].join("")     # added === for type safety

  arguments : (lhs, rhs) ->
    ret = []
    ret.push(@parse(lhs)) if lhs
    ret.push(@parse(rhs)) if rhs
    ret.join(",")

  array : (lhs) ->
    args = []
    if lhs
      args = this.parse(lhs)
      if (isArray(args))          # most probably this case is not possible
        return args
      else
        return ["[", args, "]"].join("")
    return ["[", args.join(","), "]"].join("")        # can simply write return "[]"

  function : (lhs, rhs) -> [lhs, "(", @parse(rhs), ")"].join("")

  string : (lhs) -> "'#{lhs}'"

  number : (lhs) -> lhs

  boolean : (lhs) -> lhs

  regexp : (lhs) -> lhs

  identifier : (lhs) -> lhs

  null : -> "null"

toJs = exports.toJs = (rule, scope) ->
  js = lang.parse(rule)
  scope or= {}
  vars = lang.getIdentifiers(rule)
  body = "var indexOf = definedFuncs.indexOf;" + map(vars, (v) ->
    ret = ["var ", v, " = "];
    if definedFuncs.hasOwnProperty(v)
      ret.push("definedFuncs['", v, "']")
    else if scope.hasOwnProperty(v)
      ret.push("scope['", v, "']")
    else 
      ret.push("'", v, "' in fact ? fact['", v, "'] : hash['", v, "']")
    ret.push(";")
    ret.join("")
  ).join("") + "return !!(#{js});"
  f = new Function("fact, hash, definedFuncs, scope", body)

  return (fact, hash) ->
      f(fact, hash, definedFuncs, scope)

exports.getMatcher = (rule, scope) -> toJs(rule, scope)

exports.toConstraints = (constraint, options) -> lang.toConstraints(constraint, options)

exports.equal = (c1, c2) -> lang.equal(c1, c2)

exports.getIdentifiers = (constraint) -> lang.getIdentifiers(constraint)