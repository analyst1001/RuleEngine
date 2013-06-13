###

  Defines various types of constraint objects

  TODO: Check if declarations can be replaced by class abstraction provided by coffeescript and understand the requirement of these objects

###

"use strict"

extd = require('./extended')
merge = extd.merge
instanceOf = extd.instanceOf
filter = extd.filter
declare = extd.declare
constraintMatcher = null

Constraint = declare (
  instance : 

    constructor : (type, constraint) ->
      constraintMatcher = require('./constraintMatcher') if not constraintMatcher
      @type = type
      @constraint = constraint

    assert : -> throw new Error("Not Implemented")

    equal : (constraint) ->
      instanceOf(constraint, @_static) and @get("alias") is constraint.get("alias") and extd.deepEqual(@constraint, constraint.constraint)

    getter : 
      variables : -> [@get("alias")]
)

Constraint.extend(
  instance : 
    constructor : (type) -> @_super(["object", type])

    assert : (param) -> param instanceof @constraint or param.constructor is @constraint

    equal : (constraint) -> instanceOf(constraint, @_static) and @constraint is constraint.constraint
).as(exports, "ObjectConstraint")

Constraint.extend(
  instance : 
    constructor : (constraint, options) ->
      @_super(["equality", constraint])
      options or= {}
      @pattern = options.pattern
      @_matcher = constraintMatcher.getMatcher(constraint, options.scope or {})

    assert : (values) -> @_matcher(values)
).as(exports, "EqualityConstraint")

Constraint.extend(
  instance :
    constructor : -> @_super(["equality", [true]])

    equal : (constraint) ->
      instanceOf(constraint, @_static) and @get("alias") is constraint.get("alias")

    assert : -> true
).as(exports, "TrueConstraint")

Constraint.extend(
  instance : 
    constructor : (constraint, options) ->
      @cache = {}
      @_super(["reference", constraint])
      options or= {}
      @values = []
      @pattern = options.pattern
      @_options = options
      @_matcher = constraintMatcher.getMatcher(constraint, options.scope or {})

    assert : (values) ->
      try
        @_matcher(values)
      catch e
        throw new Error("Error with evaluating pattern #{@pattern} #{e.message}")

    merge : (that) ->
      ret = this
      if that instanceof @_static
        ret = new @_static([@constraint, that.constraint, "and"], merge({}, @_options, @_options))
        ret._alias = @_alias or that._alias
        ret.vars = @vars.concat(that.vars)
      return ret

    equal : (constraint) ->
      instanceOf(constraint, @_static) and extd.deepEqual(@constraint, constraint.constraint)

    getters : 
      variables : -> @vars
      alias : -> @_alias

    setters :
      alias : (alias) ->
        @_alias = alias
        @vars = filter(constraintMatcher.getIdentifiers(@constraint), (v) -> v isnt alias )     # can be replaced by coffeescript filter
).as(exports, "ReferenceConstraint")

Constraint.extend(
  instance : 
    constructor : (hash) -> @_super(["hash", hash])

    equal : (constraint) ->
      instanceOf(constraint, @_static) and @get("alias") is constraint.get("alias") and extd.deepEqual(@constraint, constraint.constraint)

    assert : -> true

    getters : 
      variables : -> @constraint
).as(exports, "HashConstraint")