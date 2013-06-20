assert = require('assert')
Constraint = require('../src/constraint')
should = require('should')
declare = require('declare.js')

describe "Constraints objects", ->
  describe "ObjectConstraint object", ->
    describe "constructor", ->
      it "should return a proper ObjectConstraint object", ->
        constraint = "lorem ipsum"
        c1 = new Constraint.ObjectConstraint(constraint)
        assert.deepEqual(c1, {
          type : 'object'
          constraint : 'lorem ipsum'
        })

    describe "equal function", ->
      it "should return true when both the constraints are equivalent", ->
        c1 = new Constraint.ObjectConstraint("lorem ipsum")
        c2 = new Constraint.ObjectConstraint("lorem ipsum")
        assert.equal(c1.equal(c2), true)
        assert.equal(c2.equal(c1), true)

      it "should return false when both the constraints are not equivalent", ->
        c1 = new Constraint.ObjectConstraint("lorem")
        c2 = new Constraint.ObjectConstraint("ipsum")
        assert.equal(c1.equal(c2), false)
        assert.equal(c2.equal(c1), false)

    describe "assert function", ->
      Cnstrnt = declare(
        instance:
          constructor : (id) ->
            @id = id 
      )

      it "should return true when constraint is an instance of the constraint object's constraint", ->

        c1 = new Constraint.ObjectConstraint(Cnstrnt)
        c2 = new Cnstrnt(3)
        assert.equal(c1.assert(c2), true)

      it.skip "should return true when constructor of the constraint is the constraint object's constraint", ->
        c1 = new Constraint.ObjectConstraint(Cnstrnt.constructor)
        c2 = new Cnstrnt(2)
        assert.equal(c1.assert(c2), true)

      it "should return false when the constraint is neither an instance of the object's constraint neither the constructor of the constraint is the constraint object's constraint", ->
        c1 = new Constraint.ObjectConstraint(Cnstrnt)
        assert.equal(c1.assert("lorem ipsum"), false)


  describe "Equality Constraint Object", ->
    describe "constructor function", ->
      e1 = null
      condition = null
      beforeEach( ->
        condition = [ [ [ 'machine', null, 'identifier' ], [ 'type', null, 'identifier' ],'prop' ],[ 'Type1', null, 'string' ],'eq' ]
        options = 
          pattern :'machine.type == \'Type1\''
        e1 = new Constraint.EqualityConstraint(condition, options)
      )
      it "should create a proper constructor object", ->
        assert.equal(e1.type, 'equality')
        assert.equal(e1.pattern, 'machine.type == \'Type1\'')
        assert.deepEqual(e1.constraint,  condition)
        assert.equal(typeof e1._matcher, "function")          # the _matcher function gets tested in the assert function below

      describe "assert function", ->
        it "should return true if a value satisfying the condition is passed to it", ->
          val = 
            machine : 
              type : 'Type1'
          assert.equal(e1._matcher(val), true)

        it "should return false if a value not satisfying the condition is provided", ->
          val = 
            machine : 
              type : 'Type2'
          assert.equal(e1._matcher(val), false)


  describe "True constraint object", ->
    describe "constructor function", ->
      it "should create a proper True constraint object", ->
        t1 = new Constraint.TrueConstraint()
        assert.deepEqual(t1, { 
          type: 'equality'
          constraint: [ true ] 
        })

    describe "assert function", ->
      it "should always return true", ->
        t1 = new Constraint.TrueConstraint()
        assert.equal(t1.assert(), true)

    describe "equal function", ->
      it "should return true when the two constraint objects are equivalent", ->
        t1 = new Constraint.TrueConstraint()
        t2 = new Constraint.TrueConstraint()
        t1.alias = "lorem ipsum"
        t2.alias = "lorem ipsum"
        assert.equal(t1.equal(t2), true)
        assert.equal(t2.equal(t1), true)

      it "should return false when the two constraint objects are not equivalent", ->
        t1 = new Constraint.TrueConstraint()
        t2 = new Constraint.TrueConstraint()
        t1.alias = "lorem ipsum"
        t2.alias = "lorem"
        assert.equal(t1.equal(t2), false)
        assert.equal(t2.equal(t1), false)

    describe "Reference constraint object", ->
      condition = null
      options = null
      r1 = null
      beforeEach( ->
          condition = [ [ [ 'machine', null, 'identifier' ], [ 'type', null, 'identifier' ],'prop' ],[ 'Type1', null, 'string' ],'eq' ]
          options = 
            pattern :'machine.type == \'Type1\''
          r1 = new Constraint.ReferenceConstraint(condition, options)
      )
      describe "constructor function", ->
        it "should create a proper instance of the object", ->
          assert.deepEqual(r1.cache, {})
          assert.equal(r1.type, 'reference')
          assert.deepEqual(r1.values, [])
          assert.equal(r1.pattern, 'machine.type == \'Type1\'')
          assert.deepEqual(r1._options, { pattern: 'machine.type == \'Type1\'' })
          assert.equal(typeof r1._matcher, 'function')
          assert.deepEqual(r1.constraint, condition)

      describe "assert function", ->
        it "should return true when a value satisfying the condition is passed to it", ->
          val = 
            machine : 
              type : 'Type1'
          assert.equal(r1._matcher(val), true)

        it "should return false whn a value not satisfying the condition is passed to it", ->
          val = 
            machine : 
              type : 'Type2'
          assert.equal(r1._matcher(val), false)

        it "should throw an error if there is any problem evaluating the pattern", ->
          val = 
            lorem : 
              ipsum : "lorem ipsum"

          (-> r1.assert(val)).should.throw /^Error with evaluating pattern/

      describe "merge function", ->
        it "should merge the given constraint objects properly", ->
          condition2 = [ [ [ 'machine', null, 'identifier' ], [ 'type', null, 'identifier' ],'prop' ],[ 'Type2', null, 'string' ],'eq' ]
          options2 = 
            pattern :'machine.type == \'Type2\''
          r2 = new Constraint.ReferenceConstraint(condition2, options2)
          r1.set("alias", "machine")
          r2.set("alias", "machine")
          r3 = r1.merge(r2)
          assert.deepEqual(r3.cache, {})
          assert.equal(r3.type, 'reference')
          assert.deepEqual(r3.values, [])
          assert.equal(r3.pattern, 'machine.type == \'Type1\'')
          assert.deepEqual(r3._options, { pattern: 'machine.type == \'Type1\'' })
          assert.equal(r3._alias, 'machine')
          assert.deepEqual(r3.vars, [])
          assert.equal(typeof r3._matcher, 'function')
          assert.deepEqual(r3.constraint[0], [ [ [ 'machine', null, 'identifier' ],[ 'type', null, 'identifier' ],'prop' ],[ 'Type1', null, 'string' ],'eq' ])
          assert.deepEqual(r3.constraint[1], [ [ [ 'machine', null, 'identifier' ],[ 'type', null, 'identifier' ],'prop' ],[ 'Type2', null, 'string' ],'eq' ])

      describe "equal function", ->
        it "should return true when both the objects are equivalent", ->
          r2 = new Constraint.ReferenceConstraint(condition, options)
          assert.equal(r1.equal(r2), true)

        it "should return false when both the objects are not equivalent", ->
          condition2 = [ [ [ 'machine', null, 'identifier' ], [ 'type', null, 'identifier' ],'prop' ],[ 'Type2', null, 'string' ],'eq' ]
          options2 = 
            pattern :'machine.type == \'Type2\''
          r2 = new Constraint.ReferenceConstraint(condition2, options2)
          assert.equal(r1.equal(r2), false)

      describe "getter functions", ->
        r1 = null
        beforeEach( ->
          condition = [ [ [ 'machine', null, 'identifier' ], [ 'type', null, 'identifier' ],'prop' ],[ 'Type1', null, 'string' ],'eq' ]
          options = 
            pattern :'machine.type == \'Type1\''
          r1 = new Constraint.ReferenceConstraint(condition, options)
          r1.set("alias", "a")
        )

        console.log(r1)
        describe "variable", ->
          it "should return the variable list", ->
            assert.deepEqual(r1.get("variables"), [ 'machine' ])
        describe "alias", ->
          it "should return the alias", ->
            assert.equal(r1.get("alias"), 'a')

      describe "setter functions", ->
        describe "alias", ->
          it "should set the proper alias and variables list", ->
            r1.set("alias", "a")
            assert.equal(r1._alias, 'a')
            assert.deepEqual(r1.vars, ['machine'])

    describe "HashConstraint Object", ->
      h1 = null
      beforeEach( ->
        h1 = new Constraint.HashConstraint({lorem : "ipsum"})
      )
      describe "constructor function", ->
        it "should create a proper instance of HashConstraint object", ->
          h1 = new Constraint.HashConstraint({lorem : "ipsum"})
          assert.deepEqual(h1, { 
            type: 'hash'
            constraint: 
              lorem: 'ipsum'
          })

      describe "assert function", ->

        it "should always return true", ->
          assert.equal(h1.assert(), true)

      describe "equal function", ->
        it "should return true if both the constraint objects are equivalent", ->
            h2 = new Constraint.HashConstraint({lorem : "ipsum"})
            assert.equal(h1.equal(h2), true)

      describe "getter functions", ->
        describe "variables", ->
          it "should return the constraint parameter of the constraint object", ->
            assert.equal(h1.get("variables"), h1.constraint)