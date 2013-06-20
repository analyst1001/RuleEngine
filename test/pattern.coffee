assert = require('assert')
Pattern = require('../src/pattern')
should = require('should')
atoms = require('../src/constraint')

describe "Pattern objects", ->
  describe "ObjectPattern pattern", ->
    opObj = null
    c1 = null
    options = null
    beforeEach( ->
      c1 = [['a', null, 'identifier'], ['3', null, 'number'], 'eq']
      options = 
        pattern : 'a == 3'
      opObj = new Pattern.ObjectPattern('equality', 'a', c1, {}, options)
    )
    describe "constructor function", ->

      it "should create a proper ObjectPattern object", ->
        assert.equal(opObj.type, 'equality')
        assert.equal(opObj.alias, 'a')
        assert.equal(opObj.pattern, 'a == 3')
        assert.deepEqual(opObj.conditions, c1)
        assert.deepEqual(opObj.constraints[0],{ 
          type: 'object'
          constraint: 'equality'
          alias: 'a' 
        })
        assert.equal(opObj.constraints[1].type, 'equality')
        assert.equal(opObj.constraints[1].pattern, options.pattern)
        assert.equal(opObj.constraints[1].alias, 'a')
        assert.deepEqual(opObj.constraints[1].constraint, [ [ 'a', null, 'identifier' ],[ '3', null, 'number' ],'eq' ])
        assert.equal(typeof opObj.constraints[1]._matcher, 'function')

    describe "hasConstraint function", ->
      it "should return true if any constraint is present of the given type", ->
        assert.equal(opObj.hasConstraint(atoms.EqualityConstraint), true)
        assert.equal(opObj.hasConstraint(atoms.ObjectConstraint), true)

      it "should return false if no constraint of the given type is present in the constraints list", ->
        assert.equal(opObj.hasConstraint(atoms.ReferenceConstraint), false)

    describe "hashCode function", ->
      it "should return proper hash code of the object", ->
        assert.equal(opObj.hashCode(), 'equality:a:["a",null,"identifier"]')

    describe "toString function", ->
      it "should return the proper string representation of the Pattern object", ->
        assert.equal(opObj.toString(), '{"type":"object","constraint":"equality","alias":"a"}')

# Tests for the NotPattern are the same as that for the ObjectPattern

  describe "CompositePattern object", ->
    leftObj = null
    c1 = null
    options1 = null
    options2 = null
    rightObj = null
    cpObj = null
    beforeEach( ->
      c1 = [['a', null, 'identifier'], ['3', null, 'number'], 'eq']
      c2 = [['b', null, 'identifier'], ['3', null, 'number'], 'lt']
      options1 = 
        pattern : 'a == 3'
      options2 = 
        pattern : 'b < 3'
      leftObj = new Pattern.ObjectPattern('equality', 'a', c1, {}, options1)
      rightObj = new Pattern.ObjectPattern('equality', 'b', c2, {}, options2)
      cpObj = new Pattern.CompositePattern(leftObj, rightObj)
    )

    describe "constructor function", ->
      it "should create a proper CompositePattern object", ->
        assert.deepEqual(cpObj.leftPattern, leftObj)
        assert.deepEqual(cpObj.rightPattern, rightObj)

    describe "hashCode function", ->
      it "should return a proper hash code of the object", ->
        assert.equal(cpObj.hashCode(), 'equality:a:["a",null,"identifier"]:equality:b:["b",null,"identifier"]')

    describe "constraints getter", ->
      it "should return the list of constraints of left and right objects combined", ->
        assert.deepEqual(cpObj.get("constraints"), leftObj.constraints.concat(rightObj.constraints))

#no tests to be written for initial fact object

  describe "InitialFactPattern object", ->
    ifpObj = null
    beforeEach( ->
      ifpObj = new Pattern.InitialFactPattern()
    )
    describe "constructor function", ->
      it.skip "should create a proper InitialFactPattern object", ->
        assert.deepEqual(ifpObj.type, new Pattern.InitialFact())
        assert.equal(ifpObj.alias, 'i')
        assert.deepEqual(ifpObj.conditions, [])

    describe "assert function", ->
      it "should always return true", ->
        assert.equal(ifpObj.assert(), true)

