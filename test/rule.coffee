assert = require('assert')
Rule = require('../src/rule')
should = require('should')
util = require('util')
NotPattern = require('../src/pattern').NotPattern
ObjectPattern = require('../src/pattern').ObjectPattern
Promise = require('promise-extended').Promise

describe "Rule Object functions", ->
  describe "parsePattern function", ->

    describe "when object pattern condition is given", ->
      it "should create a proper rule object", ->
        Message = (message) ->
          @message = message
        opts = 
          agendaGroup : 'ag1'
          autoFocus : true
          salience : 2
        conds = [[Message, "m", "m.message =~ /^hello/"], [Message, "m", "m.message =~ /world$/"]]
        cb = ->
          return true
        r1 = Rule.createRule("Rule1", opts, conds, cb)
        assert.equal(util.inspect(r1[0].pattern, {depth: null}), '{ leftPattern: \n   { type: [Function],\n     alias: \'m\',\n     conditions: \n      [ [ [ \'m\', null, \'identifier\' ],\n          [ \'message\', null, \'identifier\' ],\n          \'prop\' ],\n        [ /^hello/, null, \'regexp\' ],\n        \'like\' ],\n     pattern: \'m.message =~ /^hello/\',\n     constraints: \n      [ { type: \'object\', constraint: [Function], alias: \'m\' },\n        { type: \'equality\',\n          constraint: \n           [ [ [ \'m\', null, \'identifier\' ],\n               [ \'message\', null, \'identifier\' ],\n               \'prop\' ],\n             [ /^hello/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'m.message =~ /^hello/\',\n          _matcher: [Function],\n          alias: \'m\' } ] },\n  rightPattern: \n   { type: [Function],\n     alias: \'m\',\n     conditions: \n      [ [ [ \'m\', null, \'identifier\' ],\n          [ \'message\', null, \'identifier\' ],\n          \'prop\' ],\n        [ /world$/, null, \'regexp\' ],\n        \'like\' ],\n     pattern: \'m.message =~ /world$/\',\n     constraints: \n      [ { type: \'object\', constraint: [Function], alias: \'m\' },\n        { type: \'equality\',\n          constraint: \n           [ [ [ \'m\', null, \'identifier\' ],\n               [ \'message\', null, \'identifier\' ],\n               \'prop\' ],\n             [ /world$/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'m.message =~ /world$/\',\n          _matcher: [Function],\n          alias: \'m\' } ] } }')

    describe "when not pattern condition is given", ->
      it "should create a proper rule object", ->
        Message = (message) ->
          @message = message
        opts = 
          agendaGroup : 'ag1'
          autoFocus : true
          salience : 2
        conds = [['not', Message, "m", "m.message =~ /^hello/"]]
        cb = ->
          return true
        r1 = Rule.createRule("Rule1", opts, conds, cb)
        assert.equal(r1[0].pattern instanceof NotPattern, true)
        assert.equal(util.inspect(r1[0].pattern, {depth : null}), '{ type: [Function],\n  alias: \'m\',\n  conditions: \n   [ [ [ \'m\', null, \'identifier\' ],\n       [ \'message\', null, \'identifier\' ],\n       \'prop\' ],\n     [ /^hello/, null, \'regexp\' ],\n     \'like\' ],\n  pattern: \'m.message =~ /^hello/\',\n  constraints: \n   [ { type: \'object\', constraint: [Function], alias: \'m\' },\n     { type: \'equality\',\n       constraint: \n        [ [ [ \'m\', null, \'identifier\' ],\n            [ \'message\', null, \'identifier\' ],\n            \'prop\' ],\n          [ /^hello/, null, \'regexp\' ],\n          \'like\' ],\n       pattern: \'m.message =~ /^hello/\',\n       _matcher: [Function],\n       alias: \'m\' } ] }')


    describe " when or pattern condition is given", ->
        it "should create a proper rule object", ->
          opts = 
            agendaGroup : 'ag1'
            autoFocus : true
            salience : 2
          conds = [ ['or', [String, "s1", "s1 =~ /^hello/"], [String, 's2', 's2 =~ /world$/'] ] ]
          cb = ->
            return true
          r1 = Rule.createRule("Rule1", opts, conds, cb)
          assert.equal(util.inspect(r1, {depth : null}), '[ { name: \'Rule1\',\n    pattern: \n     { type: [Function: String],\n       alias: \'s1\',\n       conditions: \n        [ [ \'s1\', null, \'identifier\' ],\n          [ /^hello/, null, \'regexp\' ],\n          \'like\' ],\n       pattern: \'s1 =~ /^hello/\',\n       constraints: \n        [ { type: \'object\', constraint: [Function: String], alias: \'s1\' },\n          { type: \'equality\',\n            constraint: \n             [ [ \'s1\', null, \'identifier\' ],\n               [ /^hello/, null, \'regexp\' ],\n               \'like\' ],\n            pattern: \'s1 =~ /^hello/\',\n            _matcher: [Function],\n            alias: \'s1\' } ] },\n    cb: [Function],\n    agendaGroup: \'ag1\',\n    autoFocus: true,\n    priority: 2 },\n  { name: \'Rule1\',\n    pattern: \n     { type: [Function: String],\n       alias: \'s2\',\n       conditions: \n        [ [ \'s2\', null, \'identifier\' ],\n          [ /world$/, null, \'regexp\' ],\n          \'like\' ],\n       pattern: \'s2 =~ /world$/\',\n       constraints: \n        [ { type: \'object\', constraint: [Function: String], alias: \'s2\' },\n          { type: \'equality\',\n            constraint: \n             [ [ \'s2\', null, \'identifier\' ],\n               [ /world$/, null, \'regexp\' ],\n               \'like\' ],\n            pattern: \'s2 =~ /world$/\',\n            _matcher: [Function],\n            alias: \'s2\' } ] },\n    cb: [Function],\n    agendaGroup: \'ag1\',\n    autoFocus: true,\n    priority: 2 } ]')
    
  describe "getParamTypeSwitcher Function", ->
    opts = null
    cb = null
    beforeEach( ->
      opts = 
        agendaGroup : 'ag1'
        autoFocus : true
        salience : 2
      cb = ->
        return true
    )
    it "should create a pattern of string type when type is 'string'", ->
      conds = [ ["string", "s1", "s1 =~ /^hello/"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, String)

    it "should create a pattern of date type when type is 'date'", ->
      conds = [ ["date", "d"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Date)

    it "should create a pattern of array type when type is 'array'", ->
      conds = [ [ "array", "a", "5 in a"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Array)  

    it "should create a pattern of boolean type when type is 'boolean'", ->
      conds = [ [ "boolean", "a", "a == true"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Boolean)  

    it "should create a pattern of regexp type when type is 'regexp'", ->
      conds = [ [ "regexp", "a", "a =~ /^hello/"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, RegExp)

    it "should create a pattern of number type when type is 'number'", ->
      conds = [ [ "number", "a", "a <= 5"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Number) 

    it "should create a pattern of object type when type is 'object'", ->
      conds = [ [ "object", "a", "a.x == 7"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Object)

    it "should create a pattern of regexp type when type is 'regexp'", ->
      conds = [ [ "hash", "a", "a.str =~ /^hello/"] ]
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Object)

    it "should throw an error if any non existing type is given as parameter", ->
      conds = [ [ "loremipsum", "a", "a.str =~ /^hello/"] ]
      (-> Rule.createRule("Rule1", opts, conds, cb)).should.throw /^Invalid parameter type/

  describe "getParamType function", ->
    it "should create a pattern of type array object if '[]' is given as a parameter", ->
      opts = 
        agendaGroup : 'ag1'
        autoFocus : true
        salience : 2
      conds = [ [ [], "a", "5 in a"] ]
      cb = ->
        return true
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].pattern.type, Array)  

    it "should throw an error if any non existing type is given as parameter", ->
      opts = 
        agendaGroup : 'ag1'
        autoFocus : true
        salience : 2
      conds = [ [ "loremipsum", "a", "a.str =~ /^hello/"] ]
      cb = ->
        return true
      (-> Rule.createRule("Rule1", opts, conds, cb)).should.throw /^Invalid parameter type/

  describe "createRule Function", ->
    it "should create a proper rule object", ->
      Message = (message) ->
        @message = message
      opts = 
        agendaGroup : 'ag1'
        autoFocus : true
        salience : 2
      conds = [[Message, "m", "m.message =~ /^hello/"], [Message, "m", "m.message =~ /world$/"]]
      cb = ->
        return true
      r1 = Rule.createRule("Rule1", opts, conds, cb)
      assert.equal(r1[0].name, 'Rule1')
      assert.equal(r1[0].agendaGroup, 'ag1')
      assert.equal(r1[0].autoFocus, true)
      assert.equal(r1[0].priority, 2)
      assert.equal(typeof r1[0].cb, 'function')
      assert.equal(r1[0].cb(), true)
      assert.equal(util.inspect(r1[0].pattern, {depth: null}), '{ leftPattern: \n   { type: [Function],\n     alias: \'m\',\n     conditions: \n      [ [ [ \'m\', null, \'identifier\' ],\n          [ \'message\', null, \'identifier\' ],\n          \'prop\' ],\n        [ /^hello/, null, \'regexp\' ],\n        \'like\' ],\n     pattern: \'m.message =~ /^hello/\',\n     constraints: \n      [ { type: \'object\', constraint: [Function], alias: \'m\' },\n        { type: \'equality\',\n          constraint: \n           [ [ [ \'m\', null, \'identifier\' ],\n               [ \'message\', null, \'identifier\' ],\n               \'prop\' ],\n             [ /^hello/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'m.message =~ /^hello/\',\n          _matcher: [Function],\n          alias: \'m\' } ] },\n  rightPattern: \n   { type: [Function],\n     alias: \'m\',\n     conditions: \n      [ [ [ \'m\', null, \'identifier\' ],\n          [ \'message\', null, \'identifier\' ],\n          \'prop\' ],\n        [ /world$/, null, \'regexp\' ],\n        \'like\' ],\n     pattern: \'m.message =~ /world$/\',\n     constraints: \n      [ { type: \'object\', constraint: [Function], alias: \'m\' },\n        { type: \'equality\',\n          constraint: \n           [ [ [ \'m\', null, \'identifier\' ],\n               [ \'message\', null, \'identifier\' ],\n               \'prop\' ],\n             [ /world$/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'m.message =~ /world$/\',\n          _matcher: [Function],\n          alias: \'m\' } ] } }')

  describe "Rule object", ->
    # constructor already chaecked in createRule function
    describe "fire function", ->
      it "should execute the callback function when it is executed and return a promise object", ->
        Message = (message) ->
          @message = message
        opts = 
          agendaGroup : 'ag1'
          autoFocus : true
          salience : 2
        conds = [[Message, "m", "m.message =~ /^hello/"], [Message, "m", "m.message =~ /world$/"]]
        cb = ->
          throw new Error("Callback function called")
        flow = []
        match = 
          factHash : 
            m : 
              message : "hello"

        r1 = Rule.createRule("Rule1", opts, conds, cb)
        ret = r1[0].fire(flow, match)
        assert.equal(ret instanceof Promise, true)
        assert.deepEqual(util.inspect(ret.__error), '{ \'0\': [Error: Callback function called] }')

