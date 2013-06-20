assert = require('assert')
Context = require('../src/context')
should = require('should')

describe "Context Object", ->

  describe "constructor function", ->
    it "should create a new context object if no parameters are provided", ->
      context = new Context()
      assert.deepEqual(context, {
        fact: undefined
        paths: null
        match: {
          variables: []
          facts: [ {} ]
          factIds: [ undefined ]
          factHash: {}
          recency: [ undefined ]
          constraints: []
          isMatch: true
          hashCode: ''
        },
        factHash: {}
        hashCode: ''
        factIds: [ undefined ] 
      })

    describe "should create a new context object with proper parameters when proper parameters are provided", ->
      fact = 
        id : 0
        recency : 0
        factHash : 
          lorem : "ipsum"

      paths = "paths"

      match = "match object"

      context = new Context(fact, paths)

      assert.deepEqual(context, { 
        fact: 
          id: 0
          recency: 0
          factHash: 
            lorem: 'ipsum' 
        paths: 'paths'
        match: 
          variables: []
          facts: [ {
            id: 0
            recency: 0
            factHash:
              lorem: 'ipsum' 
          }]
          factIds: [ 0 ]
          factHash: 
            lorem: 'ipsum'
          recency: [ 0 ]
          constraints: []
          isMatch: true
          hashCode: '0'
        factHash: 
          lorem: 'ipsum'
        hashCode: '0'
        factIds: [ 0 ] 
      })  

      context = new Context(fact, paths, match)

      assert.deepEqual(context, {
        fact: 
          id: 0
          recency: 0
          factHash:
            lorem: 'ipsum' 
        paths: 'paths'
        match: 'match object'
        factHash: undefined
        hashCode: undefined
        factIds: undefined
      })

  describe "set function", ->
    it "should set the facthash of the context object", ->
      context = new Context()
      context.set("lorem", "ipsum")
      assert.equal(context.factHash.lorem, "ipsum")

  describe "isMatch function", ->
    it "should set the isMatch of the match object", ->
      match = {isMatch : ''}
      context = new Context({match : match})
      context.isMatch("lorem ipsum")

      assert.equal(context.match.isMatch, "lorem ipsum")

  describe "clone function", ->

    fact = 
      id : 0
      recency : 0
      factHash : 
        lorem : "ipsum"

    paths = "paths"

    match = "match object"
      
    fact2 = 
      id : 1
      recency : 1
      factHash : 
        lorem : "lorem ipsum"

    paths2 = "lorem ipsum"

    match2 = "lorem ipsum"

    context = null

    beforeEach( ->
      context = new Context(fact, paths, match)
    )

    it "should clone the original context object if no parameters are provided", ->
      context2 = context.clone()
      assert.deepEqual(context2, {
        fact: 
          id: 0
          recency: 0
          factHash:
            lorem: 'ipsum' 
        paths: 'paths'
        match: 'match object'
        factHash: undefined
        hashCode: undefined
        factIds: undefined
      })

    it "should clone the original object except for the parameters provided", ->

      describe "when only fact object is given", ->
        context2 = context.clone(fact2)
        assert.deepEqual(context2, {
          fact: 
            id: 1
            recency: 1
            factHash:
              lorem: 'lorem ipsum' 
          paths: 'paths'
          match: 'match object'
          factHash: undefined
          hashCode: undefined
          factIds: undefined
        })

      describe "when fact and paths objects are given", ->
        context2 = context.clone(fact2, paths2)
        assert.deepEqual(context2, {
          fact: 
            id: 1
            recency: 1
            factHash:
              lorem: 'lorem ipsum' 
          paths: 'lorem ipsum'
          match: 'match object'
          factHash: undefined
          hashCode: undefined
          factIds: undefined
        })      

      describe "when fact, paths and match objects are given", ->
        context2 = new Context(fact2, paths2, match2)
        assert.deepEqual(context2, {
          fact: 
            id: 1
            recency: 1
            factHash:
              lorem: 'lorem ipsum' 
          paths: 'lorem ipsum'
          match: 'lorem ipsum'
          factHash: undefined
          hashCode: undefined
          factIds: undefined
        })    

  describe "Match object", ->

    describe "constructor", ->
      it "should create a proper match object when no arguments are provided", ->
        context = new Context()
        assert.deepEqual(context.match, {
          variables: []
          facts: [ {} ]
          factIds: [ undefined ]
          factHash: {}
          recency: [ undefined ]
          constraints: []
          isMatch: true
          hashCode: ''
        })

      it "should create a proper match object when a fact object is provided", ->
        fact = 
          id : 0
          recency : 0
          factHash :
            lorem : "ipsum"

        context = new Context(fact)
        assert.deepEqual(context.match, { 
          variables: []
          facts: [
            id: 0
            recency: 0
            factHash:
              lorem : "ipsum"
          ]
          factIds: [ 0 ]
          factHash: 
            lorem: 'ipsum'
          recency: [ 0 ]
          constraints: []
          isMatch: true
          hashCode: '0' 
        })

      it "should create a proper match object when a match object is provided"
        # fact = 
        #   id : 0
        #   recency : 0
        #   factHash :
        #     lorem : "ipsum"

        # context = new Context(fact)

        # context2 = new Context(context)

        # assert.deepEqual(context2.match)

    describe "merge function", ->
      it "should properly merge the context objects", ->
        fact = 
          id : 0
          recency : 0
          factHash:
            lorem : "ipsum"

        context = new Context(fact)

        fact2 = 
          id : 1
          recency : 1
          factHash : 
            lorem : "lorem ipsum"

        context2 = new Context(fact2)

        m = context.match.merge(context2.match)

        assert.deepEqual(m, { 
          variables: []
          facts: [ {
            id: 0
            recency: 0
            factHash: 
              lorem : "ipsum"
          }
          { 
            id: 1,
            recency: 1,
            factHash: 
              lorem : "lorem ipsum" 
          }]
          factIds: [ 0, 1 ]
          factHash:
            lorem: 'lorem ipsum'
          recency: [ 0, 1 ]
          constraints: []
          isMatch: true
          hashCode: '0:1' 
        })






