assert = require('assert')
Compile = require('../src/compile')
should = require('should')
declare = require('declare.js')
util = require('util')

Container = declare({
  instance : 
    constructor : -> 
      @name = ''
      @define = []
      @scope = []
      @rules = []
      @__defined = {}
      @__rules = []
  
    addDefined : (key, value) ->
      @__defined[key] = value
})



describe "compiling functions", ->

  describe "createDefined Function", ->
    describe "when the constructor is not defined", ->
      it "should create a function for creating the defined object if a string is passed", ->
        flowObj = new Container()
        flowObj.define.push(
          name : 'loremipsum'
          properties : '{message : "", val : 0, val2 : true}'
        )
        flowObj.name = 'Test rule'
        options = {}
        cb = -> return true
        flow = Compile.compile(flowObj, options, cb, Container)
        loremIpsum = flow.__defined['loremipsum']
        x = new loremIpsum({message : 'hello', val : 1, val2 : false, temp : 'lorem ipsum'})
        assert.deepEqual(x, { 
          message: 'hello',
          val: 1,
          val2: false 
        })

      it "should create a function for creating the defined object if an object(hash) is passed", ->
        flowObj = new Container()
        flowObj.define.push(
          name : 'loremipsum'
          properties : 
            message : ''
            val : 0
            val2 : true
        )
        flowObj.name = 'Test rule'
        options = {}
        cb = -> return true
        flow = Compile.compile(flowObj, options, cb, Container)
        loremIpsum = flow.__defined['loremipsum']
        x = new loremIpsum({message : 'hello', val : 1, val2 : false, temp : 'lorem ipsum'})
        assert.deepEqual(x, { 
          message: 'hello',
          val: 1,
          val2: false 
        })

    describe "when constructor is defined", ->
      it "should create a function for creating the defined object if a string is passed", ->
        flowObj = new Container()
        flowObj.define.push(
          name : 'loremipsum'
          properties : '{constructor : function() {this.message = "hello"; this.val = 1; this.val2 = false}, message : "", val : 0, val2 : true}'
        )
        flowObj.name = 'Test rule'
        options = {}
        cb = -> return true
        flow = Compile.compile(flowObj, options, cb, Container)
        x = new flow.__defined['loremipsum']
        assert.deepEqual(x, 
          message: 'hello',
          val: 1,
          val2: false
        )

      it "should create a function for creating the defined object if an object is passed", ->
        flowObj = new Container()
        flowObj.define.push(
          name : 'loremipsum'
          properties : 
            constructor : ->
              @message = "hello"
              @val = 1
              @val2 = false
            message : ""
            val : 0
            val2 : true
        )
        flowObj.name = 'Test rule'
        options = {}
        cb = -> return true
        flow = Compile.compile(flowObj, options, cb, Container)
        x = new flow.__defined['loremipsum']
        assert.deepEqual(x, 
          message: 'hello',
          val: 1,
          val2: false
        )
        
  describe "createFunction object", ->
    it "should throw an error if there is any problem in evaluation of function", ->
      flowObj = new Container()
      flowObj.define.push(
        name : 'Message'
        properties : 
          constructor : (mesg) ->
            @message = mesg
      )
      flowObj.scope.push( 
          name : 'ipsum'
          body : 'Result'
      )
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      (-> Compile.compile(flowObj, options, cb, Container)).should.throw  /^Invalid action :/

    it "should create a proper function object when the custom functions are defined properly", ->
      flowObj = new Container()
      flowObj.define.push(
        name : 'Message'
        properties : 
          constructor : (mesg) ->
            @message = mesg
      )
      flowObj.scope.push( 
          name : 'ipsum'
          body : 'Message'
      )
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      (-> Compile.compile(flowObj, options, cb, Container)).should.not.throw            # could only check for error not to be thrown due to encapsulation

  describe "parseAction function", ->
    it "should create a proper function object if the function is defined properly", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1', constraints : [['String', 's', 's =~ /^hello/']], action : 's += " bye";'})
      flow = Compile.compile(flowObj, options, cb, Container)
      assert.equal(typeof flow.__rules[0].cb, 'function')             # could only check for error not to be thrown doe to encapsulation

    it.skip "should throw an error if the function is not defined properly", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1', constraints : [['String', 's', 's =~ /^hello/']], action : 's -= " bye";'})
      (-> Compile.compile(flowObj, options, cb, Container)).should.throw /^Invalid action :/

  describe "createRuleFromObject function", ->
    it "should throw an error if the rule is empty", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({})
      (-> Compile.compile(flowObj, options, cb, Container)).should.throw /^Rule is empty/

    it "should throw an error if the action corresponding to the rule is undefined", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1'})
      (-> Compile.compile(flowObj, options, cb, Container)).should.throw /^No action was defined for rule/

    it "should throw an error if the type of variable in constraint is not one of the defined ones", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1', constraints : [['loremipsum', 's', 's += 10']], action: 'return true;'})
      (-> Compile.compile(flowObj, options, cb, Container)).should.throw /^Invalid class/

    it "should create proper 'not' constraint rule objects", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1', constraints : [['not', 'String', 's', 's =~ /^hello/']], action: 'return true;'})
      flow = Compile.compile(flowObj, options, cb, Container)
      assert.equal(util.inspect(flow.__rules[0], {depth: null}), '{ name: \'Rule1\',\n  pattern: \n   { type: [Function: String],\n     alias: \'s\',\n     conditions: \n      [ [ \'s\', null, \'identifier\' ],\n        [ /^hello/, null, \'regexp\' ],\n        \'like\' ],\n     pattern: \'s =~ /^hello/\',\n     constraints: \n      [ { type: \'object\', constraint: [Function: String], alias: \'s\' },\n        { type: \'equality\',\n          constraint: \n           [ [ \'s\', null, \'identifier\' ],\n             [ /^hello/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'s =~ /^hello/\',\n          _matcher: [Function],\n          alias: \'s\' } ] },\n  cb: [Function],\n  priority: 0 }')

    it "should create proper 'or' constraint rule objects", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1', constraints : [['or', ['String', 's1', 's1 =~ /^hello/'], ['String', 's2', 's2 =~ /world$/']]], action: 'return true;'})
      flow = Compile.compile(flowObj, options, cb, Container)
      assert.equal(util.inspect(flow.__rules, {depth : null}), '[ { name: \'Rule1\',\n    pattern: \n     { type: [Function: String],\n       alias: \'s1\',\n       conditions: \n        [ [ \'s1\', null, \'identifier\' ],\n          [ /^hello/, null, \'regexp\' ],\n          \'like\' ],\n       pattern: \'s1 =~ /^hello/\',\n       constraints: \n        [ { type: \'object\', constraint: [Function: String], alias: \'s1\' },\n          { type: \'equality\',\n            constraint: \n             [ [ \'s1\', null, \'identifier\' ],\n               [ /^hello/, null, \'regexp\' ],\n               \'like\' ],\n            pattern: \'s1 =~ /^hello/\',\n            _matcher: [Function],\n            alias: \'s1\' } ] },\n    cb: [Function],\n    priority: 0 },\n  { name: \'Rule1\',\n    pattern: \n     { type: [Function: String],\n       alias: \'s2\',\n       conditions: \n        [ [ \'s2\', null, \'identifier\' ],\n          [ /world$/, null, \'regexp\' ],\n          \'like\' ],\n       pattern: \'s2 =~ /world$/\',\n       constraints: \n        [ { type: \'object\', constraint: [Function: String], alias: \'s2\' },\n          { type: \'equality\',\n            constraint: \n             [ [ \'s2\', null, \'identifier\' ],\n               [ /world$/, null, \'regexp\' ],\n               \'like\' ],\n            pattern: \'s2 =~ /world$/\',\n            _matcher: [Function],\n            alias: \'s2\' } ] },\n    cb: [Function],\n    priority: 0 } ]')

    it "should create proper 'object' constraint rule objects", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.rules.push({name : 'Rule1', constraints : [['String', 's1', 's1 =~ /^hello/']], action: 'return true;'})
      flow = Compile.compile(flowObj, options, cb, Container)
      assert.equal(util.inspect(flow.__rules, {depth : null}), '[ { name: \'Rule1\',\n    pattern: \n     { type: [Function: String],\n       alias: \'s1\',\n       conditions: \n        [ [ \'s1\', null, \'identifier\' ],\n          [ /^hello/, null, \'regexp\' ],\n          \'like\' ],\n       pattern: \'s1 =~ /^hello/\',\n       constraints: \n        [ { type: \'object\', constraint: [Function: String], alias: \'s1\' },\n          { type: \'equality\',\n            constraint: \n             [ [ \'s1\', null, \'identifier\' ],\n               [ /^hello/, null, \'regexp\' ],\n               \'like\' ],\n            pattern: \'s1 =~ /^hello/\',\n            _matcher: [Function],\n            alias: \'s1\' } ] },\n    cb: [Function],\n    priority: 0 } ]')

  #parse function is already tested in parser/index.coffee tests
  describe "compile function", ->
    it "should throw an error if no name is present for the rule", ->
      flowObj = new Container()
      options = {}
      cb = -> return true
      (-> Compile.compile(flowObj, options, cb, Container)).should.throw /^Name must be present in JSON or options/

    it.skip "should create a proper Container(Flow) object when there are no errors", ->
      flowObj = new Container()
      flowObj.name = 'Test rule'
      options = {}
      cb = -> return true
      flowObj.define.push(
        name : 'loremipsum'
        properties : '{message : "", val : 0, val2 : true}'
      )
      flowObj.define.push(
        name : 'Message'
        properties : 
          constructor : (mesg) ->
            @message = mesg
      )
      flowObj.scope.push( 
          name : 'ipsum'
          body : 'Message'
      )
      flowObj.rules.push({name : 'Rule1', constraints : [['not', 'String', 's', 's =~ /^hello/'],['or', ['String', 's1', 's1 =~ /^hello/'], ['String', 's2', 's2 =~ /world$/']],['String', 's1', 's1 =~ /^hello/']], action: 'return true;'})
      flow = Compile.compile(flowObj, options, cb, Container)
      assert.equal(util.inspect(flow.__rules, {depth: null}), '[ { name: \'Rule1\',\n    pattern: \n     { leftPattern: \n        { leftPattern: \n           { type: [Function: String],\n             alias: \'s\',\n             conditions: \n              [ [ \'s\', null, \'identifier\' ],\n                [ /^hello/, null, \'regexp\' ],\n                \'like\' ],\n             pattern: \'s =~ /^hello/\',\n             constraints: \n              [ { type: \'object\', constraint: [Function: String], alias: \'s\' },\n                { type: \'equality\',\n                  constraint: \n                   [ [ \'s\', null, \'identifier\' ],\n                     [ /^hello/, null, \'regexp\' ],\n                     \'like\' ],\n                  pattern: \'s =~ /^hello/\',\n                  _matcher: [Function],\n                  alias: \'s\' } ] },\n          rightPattern: \n           { type: [Function: String],\n             alias: \'s1\',\n             conditions: \n              [ [ \'s1\', null, \'identifier\' ],\n                [ /^hello/, null, \'regexp\' ],\n                \'like\' ],\n             pattern: \'s1 =~ /^hello/\',\n             constraints: \n              [ { type: \'object\', constraint: [Function: String], alias: \'s1\' },\n                { type: \'equality\',\n                  constraint: \n                   [ [ \'s1\', null, \'identifier\' ],\n                     [ /^hello/, null, \'regexp\' ],\n                     \'like\' ],\n                  pattern: \'s1 =~ /^hello/\',\n                  _matcher: [Function],\n                  alias: \'s1\' } ] } },\n       rightPattern: \n        { type: [Function: String],\n          alias: \'s1\',\n          conditions: \n           [ [ \'s1\', null, \'identifier\' ],\n             [ /^hello/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'s1 =~ /^hello/\',\n          constraints: \n           [ { type: \'object\', constraint: [Function: String], alias: \'s1\' },\n             { type: \'equality\',\n               constraint: \n                [ [ \'s1\', null, \'identifier\' ],\n                  [ /^hello/, null, \'regexp\' ],\n                  \'like\' ],\n               pattern: \'s1 =~ /^hello/\',\n               _matcher: [Function],\n               alias: \'s1\' } ] } },\n    cb: [Function],\n    priority: 0 },\n  { name: \'Rule1\',\n    pattern: \n     { leftPattern: \n        { leftPattern: \n           { type: [Function: String],\n             alias: \'s\',\n             conditions: \n              [ [ \'s\', null, \'identifier\' ],\n                [ /^hello/, null, \'regexp\' ],\n                \'like\' ],\n             pattern: \'s =~ /^hello/\',\n             constraints: \n              [ { type: \'object\', constraint: [Function: String], alias: \'s\' },\n                { type: \'equality\',\n                  constraint: \n                   [ [ \'s\', null, \'identifier\' ],\n                     [ /^hello/, null, \'regexp\' ],\n                     \'like\' ],\n                  pattern: \'s =~ /^hello/\',\n                  _matcher: [Function],\n                  alias: \'s\' } ] },\n          rightPattern: \n           { type: [Function: String],\n             alias: \'s2\',\n             conditions: \n              [ [ \'s2\', null, \'identifier\' ],\n                [ /world$/, null, \'regexp\' ],\n                \'like\' ],\n             pattern: \'s2 =~ /world$/\',\n             constraints: \n              [ { type: \'object\', constraint: [Function: String], alias: \'s2\' },\n                { type: \'equality\',\n                  constraint: \n                   [ [ \'s2\', null, \'identifier\' ],\n                     [ /world$/, null, \'regexp\' ],\n                     \'like\' ],\n                  pattern: \'s2 =~ /world$/\',\n                  _matcher: [Function],\n                  alias: \'s2\' } ] } },\n       rightPattern: \n        { type: [Function: String],\n          alias: \'s1\',\n          conditions: \n           [ [ \'s1\', null, \'identifier\' ],\n             [ /^hello/, null, \'regexp\' ],\n             \'like\' ],\n          pattern: \'s1 =~ /^hello/\',\n          constraints: \n           [ { type: \'object\', constraint: [Function: String], alias: \'s1\' },\n             { type: \'equality\',\n               constraint: \n                [ [ \'s1\', null, \'identifier\' ],\n                  [ /^hello/, null, \'regexp\' ],\n                  \'like\' ],\n               pattern: \'s1 =~ /^hello/\',\n               _matcher: [Function],\n               alias: \'s1\' } ] } },\n    cb: [Function],\n    priority: 0 } ]')
      assert.equal( util.inspect(flow.__defined, {depth: null}),"{ Array: [Function: Array],\n  String: [Function: String],\n  Number: [Function: Number],\n  Boolean: [Function: Boolean],\n  RegExp: \n   { [Function: RegExp]\n     input: [Getter/Setter],\n     multiline: [Getter/Setter],\n     lastMatch: [Getter/Setter],\n     lastParen: [Getter/Setter],\n     leftContext: [Getter/Setter],\n     rightContext: [Getter/Setter],\n     \'$1\': [Getter/Setter],\n     \'$2\': [Getter/Setter],\n     \'$3\': [Getter/Setter],\n     \'$4\': [Getter/Setter],\n     \'$5\': [Getter/Setter],\n     \'$6\': [Getter/Setter],\n     \'$7\': [Getter/Setter],\n     \'$8\': [Getter/Setter],\n     \'$9\': [Getter/Setter] },\n  Date: [Function: Date],\n  Object: [Function: Object],\n  Buffer: \n   { [Function: Buffer]\n     isEncoding: [Function],\n     poolSize: 8192,\n     isBuffer: [Function: isBuffer],\n     byteLength: [Function],\n     concat: [Function] },\n  loremipsum: [Function],\n  Message: [Function] }")
