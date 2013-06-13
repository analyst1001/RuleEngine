###

  Defines Match and Context objects

  Match object
    variables --> ???
    facts --> list of fact objects
    factIds --> list of fact ids corresponding to fact objects
    factHash --> ???
    recency --> recency list of fact objects
    constraints --> ???
    isMatch --> ???
    hashCode --> a string representing a match object

    merge(mr) --> Match Object
      mr --> Match object to be merged with current one
    returns a merged Match Object

  Context object --> connect Match and fact objects
    match --> Match object
    factHash --> ???
    fact --> Fact object
    hashCode --> hashCode of the Match object
    paths --> ???

    set(key, value) --> Context object
      key --> ???
      value --> ???
    returns a modified Context object with key and value added to factHash

    isMatch(isMatch) --> Contect Object
      isMatch --> boolean
    returns a modified Context Object

    clone(fact, paths, match) --> Context Object
      fact --> Fact object
      paths --> ???
      match --> Match object
    returns a new Context object which differs from the current object in the parameters provided
  
###

"use strict"

extd = require("./extended")
declare = extd.declare
merge = extd.merge
union = extd.union

Match = declare(
  instance : 
    constructor : (assertable) ->
      assertable = assertable or {}
      @variables = []
      @facts = []
      @factIds = []
      @factHash = assertable.factHash or {}
      @recency = []
      @constraints = []
      @isMatch = true
      @hashCode = ""
      if assertable instanceof @_static
        @isMatch = assertable.isMatch
        @facts = @facts.concat(assertable.facts)
        @factIds = @factIds.concat(assertable.factIds)
        @hashCode = @factIds.join(":")
        @factHash = merge(factHash, assertable.factHash)
        @recency = union(@recency, assertable.recency)
      else
        fact = assertable
        if fact
          @facts.push(fact)
          @factIds.push(fact.id)
          @recency.push(fact.recency)
          @hashCode += @factIds.join(":")         # most probably it should be =. issued request

    merge : (mr) ->
      ret = new @_static()
      ret.isMatch = mr.isMatch
      ret.facts = @facts.concat(mr.facts)
      ret.factIds = @factIds.concat(mr.factIds)
      ret.hashCode = ret.factIds.join(":")
      ret.factHash = merge({}, @factHash, mr.factHash)
      ret.recency = union(@recency, mr.recency)
      return ret
)

Context = declare(
  instance : 
    match : null
    factHash : null
    fact : null
    hashCode : null
    paths : null

    constructor : (fact, paths, mr) ->
      @fact = fact
      @paths = paths or null
      match = @match = mr or new Match(fact)
      @factHash = match.factHash
      @hashCode = match.hashCode
      @factIds = match.factIds

    set : (key, value) ->
      @factHash[key] = value
      return this

    isMatch : (isMatch) ->
      @match.isMatch = isMatch
      return this

    clone : (fact, paths, match) ->
      new Context(fact or @fact, paths or @paths, match or @match)

).as(module)