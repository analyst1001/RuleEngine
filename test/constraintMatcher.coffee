assert = require('assert')
cm = require('../src/constraintMatcher')
should = require('should')
atoms = require('../../lib/constraint')

describe "Constraint Matcher functions", ->
  describe "getIdentifiers function", ->
    it "should return identifiers in a given expression converted into nested list", ->
      expr = [[[[["f",[["x",null,"identifier"],["y",null,"identifier"],"arguments"],"function"],[5,null,"number"],"eq"],[["z",null,"identifier"],["Lorem ipsum",null,"string"],"eq"],"and"],[[[["lorem",null,"identifier"],["ipsum",null,"identifier"],"prop"],[[2,null,"number"],null,"unminus"],"lt"],[["str",null,"identifier"],[{},null,"regexp"],"like"],"and"],"or"],[[["a",null,"identifier"],["b",["c",null,"identifier"],"function"],"prop"],[true,null,"boolean"],"neq"],"or"]
      assert.deepEqual(cm.getIdentifiers(expr), [ 'f','x','y','z','lorem','str','a','c' ])

  describe "equal function", ->
    describe "when the objects passed are  comparable and have same value", ->
      it "should return true", ->
        c1 = "lorem ipsum"
        c2 = "lorem ipsum"
        assert.equal(cm.equal(c1, c2), true)

    describe "when the objects passed are not comparable but represent the same type", ->
      describe "when the object passed represents a string", ->
        it "should return true if the strings have equal values", ->
          c1 = ["lorem ipsum", null, 'string']
          c2 = ["lorem ipsum", null, 'string']
          assert.equal(cm.equal(c1,c2), true)

        it "should return false if the strings do not have equal values", ->
          c1 = ["lorem", null, 'string']
          c2 = ["ipsum", null, 'string']
          assert.equal(cm.equal(c1, c2), false)

      describe "when the object passed represents a number", ->
        it "should return true if the numbers have equal values", ->
          c1 = [1, null, 'number']
          c2 = [1, null, 'number']
          assert.equal(cm.equal(c1,c2), true)
          c1 = [ [ 1, null, 'number' ],  null,  'unminus' ]
          c2 = [ [ 1, null, 'number' ],  null,  'unminus' ]
          assert.equal(cm.equal(c1,c2), true)

        it "should return false if the numbers do not have equal values", ->
          c1 = [1, null, 'number']
          c2 = [2, null, 'number']
          assert.equal(cm.equal(c1, c2), false)
          c1 = [ [ 1, null, 'number' ],  null,  'unminus' ]
          c2 = [ [ 2, null, 'number' ],  null,  'unminus' ]
          assert.equal(cm.equal(c1,c2), false)

      describe "when the object passed represents a boolean", ->
        it "should return true when both the objects represent same values", ->
          c1 = [ true, null, 'boolean' ]
          c2 = [ true, null, 'boolean' ]
          assert.equal(cm.equal(c1,c2), true)
          c1 = [ false, null, 'boolean' ]
          c2 = [ false, null, 'boolean' ]
          assert.equal(cm.equal(c1,c2), true)

        it "should return when both the objects represent different values", ->
          c1 = [ true, null, 'boolean' ]
          c2 = [ false, null, 'boolean' ]
          assert.equal(cm.equal(c1,c2), false)

      describe "when both the objects represent a regular expresssion", ->
        it "should return true when both the objects represent the same regular expression", ->
          c1 = [ '/^loremipsum/', null, 'regexp' ]
          c2 = [ '/^loremipsum/', null, 'regexp' ]
          assert.equal(cm.equal(c1,c2), true)

        it "should return false when both the objects represent different values", ->
          c1 = [ '/^lorem/', null, 'regexp' ]
          c2 = [ '/^ipsum/', null, 'regexp' ]
          assert.equal(cm.equal(c1,c2), false)    

      describe "when both the objects are identifiers", ->
        it "should return true when both the identifiers are same", ->
          c1 = ['a', null, 'identifier']
          c2 = ['a', null, 'identifier']
          assert.equal(cm.equal(c1, c2), true)

        it "should return false when both the identifiers are not same", ->
          c1 = ['a', null, 'identifier']
          c2 = ['b', null, 'identifier']
          assert.equal(cm.equal(c1,c2), false)

      describe "when both the objects are of null type", ->
        it "should return true if both the objects are null", ->
          c1 = [null, null, 'null']
          c2 = [null, null, 'null']
          assert.equal(cm.equal(c1,c2), true)

        it "should return false if any of the object is not null", ->
          c1 = ['a', null, 'null']
          c2 = [null, null, 'null']
          assert.equal(cm.equal(c1,c2), false)

      describe "when both the objects represent the same type but not a string, number, boolean, regexp, identifier, null or uminus", ->
        it "should return true when the the first two elements are equal", ->
          c1 = ['lorem', 'ipsum', 'and']
          c2 = ['lorem', 'ipsum', 'and']
          assert.equal(cm.equal(c1, c2), true)

        it "should return false when the first two elements are not equal", ->
          c1 = ['lorem', 'ipsum', 'and']
          c2 = ['ipsum', 'lorem', 'and']
          assert.equal(cm.equal(c1, c2), false)

  describe "toConstraints function", ->
    options = null
    beforeEach( -> options = {})
    it "should return a list of constraint objects given constraints in list format and options", ->
      describe "when the atoms are connected by 'and'", ->
        c1 = [ [ [ 'a', null, 'identifier' ],[ '3', null, 'number' ],'or' ],[ [ 'b', null, 'identifier' ],[ 'hello', null, 'string' ],'or' ],'and' ]
        options.alias = 'a'
        ret = cm.toConstraints(c1, options)
        assert.equal(ret.length, 2)
        assert.equal(ret[0].type, 'equality')
        assert.equal(ret[0].pattern, undefined)
        assert.equal(typeof ret[0]._matcher, 'function')
        assert.deepEqual(ret[0].constraint, c1[0])
        assert.deepEqual(ret[1].cache, {})
        assert.equal(ret[1].type, 'reference')
        assert.deepEqual(ret[1].values, [])
        assert.equal(ret[1].pattern, undefined)
        assert.deepEqual(ret[1]._options, {alias : 'a'})
        assert.deepEqual(typeof ret[1]._matcher, 'function')
        assert.deepEqual(ret[1].constraint, c1[1])

      describe "when the atoms are connected by connector other than 'and'", ->
        c1 = [['a', null, 'identifier'], ['b', null, 'identifier'], 'or']
        options.alias = 'a'
        ret = cm.toConstraints(c1, options)
        assert.deepEqual(ret[0].cache, {})
        assert.equal(ret[0].type, 'reference')
        assert.deepEqual(ret[0].values, [])
        assert.equal(ret[0].pattern, undefined)
        assert.deepEqual(ret[0]._options, {alias : 'a'})
        assert.deepEqual(typeof ret[0]._matcher, 'function')
        assert.deepEqual(ret[0].constraint, c1)

        c2 = [['a', null, 'identifier'], ['3', null, 'number'], 'composite']
        ret = cm.toConstraints(c2, options)
        assert.equal(ret[0].type, 'equality')
        assert.equal(ret[0].pattern, undefined)
        assert.equal(typeof ret[0]._matcher, 'function')
        assert.deepEqual(ret[0].constraint, c2)

  describe "getMatcher function", ->
    it "should return a function", ->
      c1 = [['a', null, 'identifier'], ['3', null, 'number'], 'or']
      assert.equal(typeof cm.getMatcher(c1), 'function')

    it "should return a function which checks the condition in the list format", ->
      c1 = [['a', null, 'identifier'], ['3', null, 'number'], 'eq']
      facts = 
        a : 3
      retF = cm.getMatcher(c1)
      assert.equal(retF(facts), true)
      facts.a = 2
      assert.equal(retF(facts), false)

      c2 = [['b', null, 'identifier'], ['lorem ipsum', null, 'string'], 'eq']
      facts = 
        b : 'lorem ipsum'
      retF = cm.getMatcher(c2)
      assert.equal(retF(facts), true)
      facts.b = 'psum lorem'
      assert.equal(retF(facts), false)

# test for toJs function are same as the tests for getMatcher function





