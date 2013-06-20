assert = require('assert')
wm = require('../src/workingMemory')
should = require('should')

describe "Working memory objects", ->
  describe "Fact object", ->
    describe "constructor", ->
      it "should properly construct fact object", ->
        obj = {lorem : 'ipsum'}
        fact = new wm.Fact(obj)

        assert.deepEqual(fact.object, {
            lorem : "ipsum"
        })

    describe "hashCode function", ->
      it "should return the id of the fact", ->
        fact = new wm.Fact(null)
        assert.equal(fact.hashCode(), fact.id)

    describe "equals function", ->
      it "should return true when two fact objects are equivalent", ->
        obj = "lorem ipsum"
        fact = new wm.Fact(obj)
        fact2 = new wm.Fact(obj)

        assert.equal(fact.equals(fact2), true)
        assert.equal(fact.equals(obj), true)

      it "should return false when the two fact objects are not equivalent", ->
        obj1 = "lorem ipsum"
        obj2 = {lorem : "ipsum"}
        fact1 = new wm.Fact(obj1)
        fact2 = new wm.Fact(obj2)

        assert.equal(fact1.equals(fact2), false)
        assert.equal(fact2.equals(fact1), false)
        assert.equal(fact1.equals(obj2), false)
        assert.equal(fact2.equals(obj1), false)

      it "should return false when the fact to be checked for equivalence is null", ->
        obj1 = "lorem ipsum"
        fact1 = new wm.Fact(obj1)
        assert.equal(fact1.equals(null), false)

  describe "working memory object", ->
    describe "constructor", ->
      it "should create a proper object", ->
        wm1 = new wm.WorkingMemory()
        assert.deepEqual(wm1, {
          recency : 0
          facts : []
        })

    describe "dispose function", ->
      it "should empty the facts list when  called", ->
        wm1 = new wm.WorkingMemory()
        wm1.facts.push(1,2,3,4,5,6,7)
        wm1.dispose()
        assert.equal(wm1.facts.length, 0)

    describe "assertFact function", ->
      it "should insert the fact in the facts list", ->
        obj1 = "lorem ipsum"
        obj2 = {lorem : "ipsum"}
        fact1 = new wm.Fact(obj1)
        fact2 = new wm.Fact(obj2)

        wm1 = new wm.WorkingMemory()
        wm1.assertFact(fact1)
        wm1.assertFact(fact2)
        assert.notEqual(wm1.facts.indexOf(fact1), -1)
        assert.notEqual(wm1.facts.indexOf(fact2), -1)

      it "should throw an error if the fact object is null", ->
        fact1 = new wm.Fact(null)
        wm1 = new wm.WorkingMemory()
        (-> wm1.assertFact(fact1)).should.throw /^The fact asserted cannot be null!/

      it "should set the recency of the facts properly", ->
        obj1 = "lorem ipsum"
        obj2 = {lorem : "ipsum"}
        fact1 = new wm.Fact(obj1)
        fact2 = new wm.Fact(obj2)
        wm1 = new wm.WorkingMemory()
        wm1.assertFact(fact1)
        wm1.assertFact(fact2)
        assert.equal(wm1.facts[1].recency, wm1.recency - 1)
        assert.equal(wm1.facts[0].recency, wm1.recency - 2)

      it "should return the asserted fact", ->
        obj1 = "lorem ipsum"
        obj2 = {lorem : "ipsum"}
        fact1 = new wm.Fact(obj1)
        fact2 = new wm.Fact(obj2)
        wm1 = new wm.WorkingMemory()
        assert.deepEqual(wm1.assertFact(fact1), fact1)
        assert.deepEqual(wm1.assertFact(fact2), fact2)

    describe "modifyFact function", ->
      wm1 = null
      wm2 = null
      fact1 = null
      fact2 = null
      beforeEach( ->
        obj1 = "lorem ipsum"
        obj2 = {lorem : "ipsum"}
        fact1 = new wm.Fact(obj1)
        fact2 = new wm.Fact(obj2)
        wm1 = new wm.WorkingMemory()
        wm1.assertFact(fact1)
        wm1.assertFact(fact2)
      )

      it "should return the existing fact if the fact exists in working memory", ->
        assert.deepEqual(wm1.modifyFact(fact1), fact1)

      it "should throw an error if the fact to be modified doesn't exists in the working memory", ->
        fact3 = new wm.Fact("lorem ipsum lorem ipsum")
        (-> wm1.modifyFact(fact3)).should.throw /^The fact to modify does not exists/

    describe "retractFact function", ->
      wm1 = null
      wm2 = null
      fact1 = null
      fact2 = null
      beforeEach( ->
        obj1 = "lorem ipsum"
        obj2 = {lorem : "ipsum"}
        fact1 = new wm.Fact(obj1)
        fact2 = new wm.Fact(obj2)
        wm1 = new wm.WorkingMemory()
        wm1.assertFact(fact1)
        wm1.assertFact(fact2)
      )
      it "should remove the existing fact if it is present in the working memory", ->
        wm1.retractFact(fact1)
        assert.equal(wm1.facts.indexOf(fact1), -1)

      it "should not remove any other fact than the fact to be removed", ->
        wm1.retractFact(fact1)
        assert.notEqual(wm1.facts.indexOf(fact2), -1)

      it "should throw an error if the fact to be removed does not exists in the working memory", ->
        fact3 = "lorem ipsum lorem ipsum"
        (-> wm1.retractFact(fact3)).should.throw /^The fact to remove does not exists/

      it "should return the removed fact", ->
        assert.equal(wm1.retractFact(fact1), fact1)
        assert.equal(wm1.retractFact(fact2), fact2)
