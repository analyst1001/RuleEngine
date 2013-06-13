do ->
  "use strict"

  extd = require('./extended')
  merge = extd.merge
  forEach = extd.forEach
  declare = extd.declare
  constraintMatcher = require('./constraintMatcher')
  constraint = require('./constraint')

  Pattern = declare({});

  ObjectPattern = Pattern.extend(
    instance : 
      constructor : (type, alias, conditions, store, options) ->
        options or= {}
        @type = type
        @alias = alias
        @conditions = conditions
        @pattern = options.pattern
        @constraints = [new constraint.ObjectConstraint(type)]
        constrnts = constraintMatcher.toConstraints(conditions, merge({alias: alias}, options))
        if constrnts.length then @constraints = @constraints.concat(constrnts) else @constraints.push(new constraint.TrueConstraint())      # constructor directly passed
        if store and not extd.isEmpty(store)
          @constraints.push(new constraint.HashConstraint(store))      # constructor directly passed
        cnstrnt.set("alias", alias) for cnstrnt in @constraints 


      hasConstraint : (type) ->
        extd.some(@constraints, (c) -> c instanceof type)

      hashCode : -> [@type, @alias, extd.format("%j", @conditions)].join(":")

      toString : -> extd.format("%j", @constraints)
  ).as(exports, "ObjectPattern")

  ObjectPattern.extend().as(exports, "NotPattern")

  Pattern.extend(
    instance : 
      constructor : (left, right) ->
        @leftPattern = left
        @rightPattern = right

      hashCode : -> [@leftPattern.hashCode(), @rightPattern.hashCode()].join(":")

      getters : 
        constraints : -> @leftPattern.constraints.concat(@rightPattern.constraints)

  ).as(exports, "CompositePattern")

  InitialFact = declare({}).as(exports, "InitialFact")

  ObjectPattern.extend(
    instance : 
      constructor : -> 
        @_super([InitialFact, "i", [], {}])

      assert : -> true 
  ).as(exports, "InitialFactPattern")