###

  Declare Fact object and Working memory Object

  Fact Object
    object --> ???
    recency --> an integer representing recency of fact in working memory
    id --> a unique integer representing each rule object
    equals(fact) --> Boolean
      fact --> a fact object
    returns if the fact parameter is equal to the current fact object implying both facts are same

  WorkingMemory Object
    recency --> an integer to set the recency of facts in fact list
    facts --> a list of facts currently present in working memory
    
    dispose() --> Nothing
    removes all facts from the working memory

    assertFact(fact) --> Fact object
      fact --> the Fact object to be pushed in memory
    return the fact parameter after pushing it in working memory

    modifyFact(fact) --> Fact object
      fact --> the Fact object to be modified
    returns the fact parameter from working memory if it is present in working memory

    retractFact(fact) --> Fact object
      fact --> the Fact object to be removed from the working memory
    returns the fact parameter from the working memory after removing it from the working memory


###

"use strict"

declare = require("declare.js")

id = 0

declare(
  instance : 
    constructor : (obj) ->
      @object = obj
      @recency = 0
      @id = id++

    equals : (fact) ->
      fact isnt null and (if fact instanceof @_static then fact.object is @object else fact is @object)

    hashCode : -> @id

).as(exports, "Fact")

declare(
  instance : 
    constructor : () ->
      @recency = 0
      @facts = []

    dispose : -> @facts.length = 0

    assertFact : (fact) ->
      if fact.object is null
        throw new Error("The fact asserted cannot be null!")
      fact.recency = @recency++
      @facts.push(fact)
      return fact

    modifyFact : (fact) ->
      return existingFact for existingFact in @facts when existingFact.equals(fact)
      throw new Error("The fact to modify does not exists")

    retractFact : (fact) -> 
      facts = @facts
      for existingFact, i in facts
        if existingFact.equals(fact)
          @facts.splice(i, 1)
          return existingFact
      throw new Error("The fact to remove does not exists")

).as(exports, "WorkingMemory")