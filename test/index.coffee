assert = require('assert')
nools = require('../src/index')
should = require('should')
util = require('util')
extd = require('array-extended')
fs = require('fs')

flowName = 'loremipsum'
describe "nools main and flow functions", ->
  describe "getFlow function", ->
    it "should return the flow object with the given name", ->
      f1 = nools.flow(flowName)
      f2 = nools.getFlow(flowName)
      assert.equal(f1, f2)
      nools.deleteFlow(f1)

  describe "deleteFlow function", ->
    describe "when flow name is given", ->
      it "should delete the flow object with the given name", ->
        f1 = nools.flow(flowName)
        nools.deleteFlow(flowName)
        assert.equal(nools.getFlow(flowName), undefined)

      it "should delete the flow object when the flow Object is passed", ->
        f1 = nools.flow(flowName)
        nools.deleteFlow(f1)
        assert.equal(nools.getFlow(flowName), undefined)

  describe "parse Function", ->
    it "should parse the rules properly if a filename is given as parameter", ->
      p = nools.parse('./rule.nools')
      assert.equal(util.inspect(p, {depth:null}), '{ define: \n   [ { name: \'Machine\',\n       properties: \'({   type :\\\'\\\',   function : \\\'\\\',   testsList : [],   message : \\\'\\\',   constructor: function(t, f) {     this.type = t;     this.function = f;     this.testsList = [];     this.message = \\\'\\\';   } })\' },\n     { name: \'Test\',\n       properties: \'({   id : 0,   constructor : function(id) {     this.id = id;   } })\' } ],\n  rules: \n   [ { name: \'Tests for type1 m\',\n       options: { priority: 100 },\n       constraints: [ [ \'Machine\', \'m\', \'m.type == \\\'Type1\\\'\' ] ],\n       action: \'console.log("Type1");     var test1 = new Test(1);     var test2 = new Test(2);     var test3 = new Test(3);     m.message += "Rule Type1 Applied";     m.testsList.push(test1);     m.testsList.push(test2);     m.testsList.push(test3);   \' },\n     { name: \'Tests for type2, DNS server m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'DNS Server\\\')\' ] ],\n       action: \'console.log("Type2 DNS Server");     var test5 = new Test(5);     var test4 = new Test(4);     m.message += "Rule Type2 DNS server applied";     m.testsList.push(test5);     m.testsList.push(test4);   \' },\n     { name: \'Tests for type2, DDNS server m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'DDNS Server\\\')\' ] ],\n       action: \'console.log("Type2 DDNS Server");     var test2 = new Test(2);     var test3 = new Test(3);     m.message += "Rule Type2 DDNS server applied";     m.testsList.push(test2);     m.testsList.push(test3);   \' },\n     { name: \'Tests for type2, Gateway m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'Gateway\\\')\' ] ],\n       action: \'console.log("Type2 Gateway");     var test3 = new Test(3);     var test4 = new Test(4);     m.message += "Rule Type2 Gatewayapplied";     m.testsList.push(test3);     m.testsList.push(test4);   \' },\n     { name: \'Tests for type2, Router m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'Router\\\')\' ] ],\n       action: \'console.log("Type2 Router");     var test3 = new Test(3);     var test1 = new Test(1);     m.message += "Rule Type2 Router applied";     m.testsList.push(test3);     m.testsList.push(test1);    \' } ],\n  scope: [] }')

    it "should parse the rules properly if the rules are given as a string", ->
      ruleStr = fs.readFileSync('./rule.nools', 'utf-8')
      p = nools.parse(ruleStr)
      assert.equal(util.inspect(p, {depth:null}), '{ define: \n   [ { name: \'Machine\',\n       properties: \'({   type :\\\'\\\',   function : \\\'\\\',   testsList : [],   message : \\\'\\\',   constructor: function(t, f) {     this.type = t;     this.function = f;     this.testsList = [];     this.message = \\\'\\\';   } })\' },\n     { name: \'Test\',\n       properties: \'({   id : 0,   constructor : function(id) {     this.id = id;   } })\' } ],\n  rules: \n   [ { name: \'Tests for type1 m\',\n       options: { priority: 100 },\n       constraints: [ [ \'Machine\', \'m\', \'m.type == \\\'Type1\\\'\' ] ],\n       action: \'console.log("Type1");     var test1 = new Test(1);     var test2 = new Test(2);     var test3 = new Test(3);     m.message += "Rule Type1 Applied";     m.testsList.push(test1);     m.testsList.push(test2);     m.testsList.push(test3);   \' },\n     { name: \'Tests for type2, DNS server m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'DNS Server\\\')\' ] ],\n       action: \'console.log("Type2 DNS Server");     var test5 = new Test(5);     var test4 = new Test(4);     m.message += "Rule Type2 DNS server applied";     m.testsList.push(test5);     m.testsList.push(test4);   \' },\n     { name: \'Tests for type2, DDNS server m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'DDNS Server\\\')\' ] ],\n       action: \'console.log("Type2 DDNS Server");     var test2 = new Test(2);     var test3 = new Test(3);     m.message += "Rule Type2 DDNS server applied";     m.testsList.push(test2);     m.testsList.push(test3);   \' },\n     { name: \'Tests for type2, Gateway m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'Gateway\\\')\' ] ],\n       action: \'console.log("Type2 Gateway");     var test3 = new Test(3);     var test4 = new Test(4);     m.message += "Rule Type2 Gatewayapplied";     m.testsList.push(test3);     m.testsList.push(test4);   \' },\n     { name: \'Tests for type2, Router m\',\n       options: { priority: 100 },\n       constraints: \n        [ [ \'Machine\',\n            \'m\',\n            \'(m.type == \\\'Type2\\\') && (m.function == \\\'Router\\\')\' ] ],\n       action: \'console.log("Type2 Router");     var test3 = new Test(3);     var test1 = new Test(1);     m.message += "Rule Type2 Router applied";     m.testsList.push(test3);     m.testsList.push(test1);    \' } ],\n  scope: [] }')

  describe "compile function", ->
    it "should throw an error if name of the flow is not defined", ->
      ruleStr = fs.readFileSync('./rule.nools', 'utf-8')
      (-> nools.compile(ruleStr)).should.throw /^Name required when compiling nools source/

      it "should return a flow object if everything is proper", ->
        flow = nools.compile('./rule.nools')
        assert.equal( util.inspect(flow, {depth : null}),'{ env: null,\n  name: \'rule\',\n  cb: undefined,\n  __rules: \n   [ { name: \'Tests for type1 m\',\n       pattern: \n        { type: [Function],\n          alias: \'m\',\n          conditions: \n           [ [ [ \'m\', null, \'identifier\' ],\n               [ \'type\', null, \'identifier\' ],\n               \'prop\' ],\n             [ \'Type1\', null, \'string\' ],\n             \'eq\' ],\n          pattern: \'m.type == \\\'Type1\\\'\',\n          constraints: \n           [ { type: \'object\', constraint: [Function], alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ \'m\', null, \'identifier\' ],\n                    [ \'type\', null, \'identifier\' ],\n                    \'prop\' ],\n                  [ \'Type1\', null, \'string\' ],\n                  \'eq\' ],\n               pattern: \'m.type == \\\'Type1\\\'\',\n               _matcher: [Function],\n               alias: \'m\' } ] },\n       cb: [Function],\n       priority: 100 },\n     { name: \'Tests for type2, DNS server m\',\n       pattern: \n        { type: [Function],\n          alias: \'m\',\n          conditions: \n           [ [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'type\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'Type2\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'function\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'DNS Server\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             \'and\' ],\n          pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'DNS Server\\\')\',\n          constraints: \n           [ { type: \'object\', constraint: [Function], alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'type\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'Type2\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'DNS Server\\\')\',\n               _matcher: [Function],\n               alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'function\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'DNS Server\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'DNS Server\\\')\',\n               _matcher: [Function],\n               alias: \'m\' } ] },\n       cb: [Function],\n       priority: 100 },\n     { name: \'Tests for type2, DDNS server m\',\n       pattern: \n        { type: [Function],\n          alias: \'m\',\n          conditions: \n           [ [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'type\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'Type2\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'function\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'DDNS Server\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             \'and\' ],\n          pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'DDNS Server\\\')\',\n          constraints: \n           [ { type: \'object\', constraint: [Function], alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'type\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'Type2\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'DDNS Server\\\')\',\n               _matcher: [Function],\n               alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'function\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'DDNS Server\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'DDNS Server\\\')\',\n               _matcher: [Function],\n               alias: \'m\' } ] },\n       cb: [Function],\n       priority: 100 },\n     { name: \'Tests for type2, Gateway m\',\n       pattern: \n        { type: [Function],\n          alias: \'m\',\n          conditions: \n           [ [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'type\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'Type2\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'function\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'Gateway\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             \'and\' ],\n          pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'Gateway\\\')\',\n          constraints: \n           [ { type: \'object\', constraint: [Function], alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'type\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'Type2\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'Gateway\\\')\',\n               _matcher: [Function],\n               alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'function\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'Gateway\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'Gateway\\\')\',\n               _matcher: [Function],\n               alias: \'m\' } ] },\n       cb: [Function],\n       priority: 100 },\n     { name: \'Tests for type2, Router m\',\n       pattern: \n        { type: [Function],\n          alias: \'m\',\n          conditions: \n           [ [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'type\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'Type2\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             [ [ [ [ \'m\', null, \'identifier\' ],\n                   [ \'function\', null, \'identifier\' ],\n                   \'prop\' ],\n                 [ \'Router\', null, \'string\' ],\n                 \'eq\' ],\n               null,\n               \'composite\' ],\n             \'and\' ],\n          pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'Router\\\')\',\n          constraints: \n           [ { type: \'object\', constraint: [Function], alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'type\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'Type2\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'Router\\\')\',\n               _matcher: [Function],\n               alias: \'m\' },\n             { type: \'equality\',\n               constraint: \n                [ [ [ [ \'m\', null, \'identifier\' ],\n                      [ \'function\', null, \'identifier\' ],\n                      \'prop\' ],\n                    [ \'Router\', null, \'string\' ],\n                    \'eq\' ],\n                  null,\n                  \'composite\' ],\n               pattern: \'(m.type == \\\'Type2\\\') && (m.function == \\\'Router\\\')\',\n               _matcher: [Function],\n               alias: \'m\' } ] },\n       cb: [Function],\n       priority: 100 } ],\n  __defined: \n   { array: [Function: Array],\n     string: [Function: String],\n     number: [Function: Number],\n     boolean: [Function: Boolean],\n     regexp: \n      { [Function: RegExp]\n        input: [Getter/Setter],\n        multiline: [Getter/Setter],\n        lastMatch: [Getter/Setter],\n        lastParen: [Getter/Setter],\n        leftContext: [Getter/Setter],\n        rightContext: [Getter/Setter],\n        \'$1\': [Getter/Setter],\n        \'$2\': [Getter/Setter],\n        \'$3\': [Getter/Setter],\n        \'$4\': [Getter/Setter],\n        \'$5\': [Getter/Setter],\n        \'$6\': [Getter/Setter],\n        \'$7\': [Getter/Setter],\n        \'$8\': [Getter/Setter],\n        \'$9\': [Getter/Setter] },\n     date: [Function: Date],\n     object: [Function: Object],\n     buffer: \n      { [Function: Buffer]\n        isEncoding: [Function],\n        poolSize: 8192,\n        isBuffer: [Function: isBuffer],\n        byteLength: [Function],\n        concat: [Function] },\n     machine: [Function],\n     test: [Function] },\n  __wmAltered: false,\n  workingMemory: { recency: 0, facts: [] } }')

  describe "Flow container object", ->
    describe "constructor function", ->
      it "should throw an error if a flow with same name is already defined", ->
        f1 = nools.flow(flowName)
        (-> nools.flow(flowName)).should.throw "Flow with #{flowName} already defined"
        nools.deleteFlow(f1)

      it "should create a proper FlowContainer object if parameters are correct", ->
        cb = -> return true
        f1 = nools.flow(flowName, cb)
        assert.equal(util.inspect(f1, {depth : null}),'{ env: null,\n  name: \'loremipsum\',\n  cb: [Function],\n  __rules: [],\n  __defined: {},\n  __wmAltered: false,\n  workingMemory: { recency: 0, facts: [] } }' )
        nools.deleteFlow(f1)

    describe "__assertFact function", ->
      it "should put a fact in the working memory", ->
        f1 = nools.flow(flowName)
        f1.__assertFact('lorem ipsum')
        assert.equal(f1.workingMemory.facts[0], 'lorem ipsum')
        assert.equal(f1.workingMemory.recency, 1)
        f1.__assertFact('ipsum lorem')
        assert.equal(f1.workingMemory.facts[1], 'ipsum lorem')
        assert.equal(f1.workingMemory.recency, 2)
        nools.deleteFlow(f1)

    describe "__retractFact function", ->
      it "should remove the existing fact from working memory", ->
        String.prototype.equals = (str) ->
          return this.valueOf() is str
        f1 = nools.flow(flowName)
        f1.__assertFact('lorem ipsum')
        f1.__retractFact('lorem ipsum')
        assert.equal(f1.workingMemory.facts.indexOf('lorem ipsum'), -1)
        nools.deleteFlow(f1)

    describe "dispose function", ->
      it "should dispose the working memory", ->
        f1 = nools.flow(flowName)
        f1.__assertFact('lorem ipsum')
        f1.__assertFact('ipsum lorem')
        f1.dispose()
        assert.equal(f1.workingMemory.facts.length, 0)
        nools.deleteFlow(f1)

    describe "addDefined function", ->
      it "should add the defined object to the flow object", ->
        f1 = nools.flow(flowName)
        f1.addDefined('lorem', 'ipsum')
        assert.equal(f1.__defined['lorem'], 'ipsum')
        nools.deleteFlow(f1)

    describe "getDefined function", ->
      it "should throw an error if the object is not defined already", ->
        f1 = nools.flow(flowName)
        (-> f1.getDefined('lorem')).should.throw /flow class is not defined$/
        nools.deleteFlow(flowName)

      it "should return the defined object if it is already present in the flow", ->
        f1 = nools.flow(flowName)
        f1.addDefined('lorem', 'ipsum')
        assert.equal(f1.getDefined('lorem'), 'ipsum')
        nools.deleteFlow(f1)

    describe "__factHelper function", ->
      it "should insert a fact object in the working memory if true is passed as second parameter", ->
        f1 = nools.flow(flowName)
        f1.__factHelper('lorem ipsum', true)
        assert.equal(f1.workingMemory.facts[0].object, 'lorem ipsum')
        nools.deleteFlow(f1)

      it "should delete the fact object from the working memory if false is passed as the second parameter", ->
        f1 = nools.flow(flowName)
        f1.__factHelper('lorem ipsum', true)
        f1.__factHelper('lorem ipsum', false)
        assert.equal(f1.workingMemory.facts.length, 0)
        nools.deleteFlow(f1)

    describe "assert function", ->
      it "should insert a fact into the working memory and set working memory altered flag true", ->
        f1 = nools.flow(flowName)
        f1.assert('lorem ipsum')
        assert.equal(f1.workingMemory.facts[0].object, 'lorem ipsum')
        assert.equal(f1.__wmAltered, true)
        nools.deleteFlow(f1)

    # describe "retract function", ->
    #   it "should remove the existing fact from the working memory and set working memory altered flag false", ->
    #     f1 = nools.flow(flowName)
    #     f1.assert('lorem ipsum')
    #     f1.assert('ipsum lorem')
    #     f1.retract('ipsum lorem')
    #     assert.equal(extd.pluck(f1.workingMemory.facts, 'object').indexOf('ipsum lorem'), -1)
    #     assert.equal(f1.__wmAltered, false)
    #     nools.deleteFlow(f1)

    describe "rule function", ->
      it "should add the rule to the flow", ->
        Message = (message) ->
          @message = message
        opts = 
          agendaGroup : 'ag1'
          autoFocus : true
          salience : 2
        cb = ->
          return true
        conds = [[Message, "m", "m.message =~ /^hello/"], [Message, "m", "m.message =~ /world$/"]]
        f1 = nools.flow(flowName)
        f1.rule("Rule1", opts, conds, cb)
        assert.equal(util.inspect(f1.__rules[0]), '{ name: \'Rule1\',\n  pattern: \n   { leftPattern: \n      { type: [Function],\n        alias: \'m\',\n        conditions: [Object],\n        pattern: \'m.message =~ /^hello/\',\n        constraints: [Object] },\n     rightPattern: \n      { type: [Function],\n        alias: \'m\',\n        conditions: [Object],\n        pattern: \'m.message =~ /world$/\',\n        constraints: [Object] } },\n  cb: [Function],\n  agendaGroup: \'ag1\',\n  autoFocus: true,\n  priority: 2 }')
        nools.deleteFlow(f1)

    describe "getSession function", ->
      it "should assert all the instances of facts passed to it", ->
        f1 = nools.flow(flowName)
        f1.getSession('lorem', 'ipsum', 'lorem ipsum')
        assert.equal(f1.workingMemory.facts.length, 3)
        assert.deepEqual(extd.pluck(f1.workingMemory.facts, 'object'), ['lorem', 'ipsum', 'lorem ipsum'])
        nools.deleteFlow(f1)

    describe "containsRule function", ->
      f1 = null
      beforeEach( ->
        Message = (message) ->
          @message = message
        opts = 
          agendaGroup : 'ag1'
          autoFocus : true
          salience : 2
        cb = ->
          return true
        conds = [[Message, "m", "m.message =~ /^hello/"], [Message, "m", "m.message =~ /world$/"]]
        f1 = nools.flow(flowName)
        f1.rule("Rule1", opts, conds, cb)
        conds = [["String", "s", "s =~ /world$/"]]
        f1.rule("Rule2", opts, conds, cb)
      )
      
      it "should return true if the rule is present in the flow", ->
        assert.equal(f1.containsRule("Rule2"), true)
        nools.deleteFlow(f1)

      it "should return false if the rule is not present in the flow", ->
        assert.equal(f1.containsRule("Rule3"), false)
        nools.deleteFlow(f1)

    describe "checkFire function", ->
      it "should return true if there are facts such that all the constraints of the rule are satisfied", ->
        f = 
          satisfyingFacts : [['lorem ipsum', 'ipsum lorem'], ['loremipsum', 'ipsumlorem']]
        f1 = nools.flow(flowName)
        assert.equal(f1.checkFire(f), true)
        nools.deleteFlow(f1)

      it "should return false if no fact satisfies any rules", ->
        f = 
          satisfyingFacts : []
        f1 = nools.flow(flowName)
        assert.equal(f1.checkFire(f), false)
        nools.deleteFlow(f1)

      it "should return false if one of the constraints of a rule is not satisfied by any of the facts", ->
        f = 
          satisfyingFacts : [['lorem ipsum', 'ipsum lorem'], [], ['loremipsum', 'ipsumlorem']]
        f1 = nools.flow(flowName)
        assert.equal(f1.checkFire(f), false)
        nools.deleteFlow(f1)

    describe "makeConstraintsList function", ->
      it "should create a list of constraints from given tree of constraints", ->
        Message = (message) ->
            @message = message
        opts = 
          agendaGroup : 'ag1'
          autoFocus : true
          salience : 2
        cb = ->
          return true
        conds = [[Message, "m", "m.message =~ /^hello/"], [Message, "m", "m.message =~ /world$/"], ["String", "s", "s =~ /^good/"]]
        f1 = nools.flow(flowName)
        f1.rule("Rule1", opts, conds, cb)
        f1.__rules[0].constraintsList = []
        f1.makeConstraintsList(f1.__rules[0], f1.__rules[0].pattern)
        assert.equal(f1.__rules[0].constraintsList.length, 3)
        assert.equal(f1.__rules[0].pattern.leftPattern.leftPattern.constraints in f1.__rules[0].constraintsList, true)
        assert.equal(f1.__rules[0].pattern.leftPattern.rightPattern.constraints in f1.__rules[0].constraintsList, true)
        assert.equal(f1.__rules[0].pattern.rightPattern.constraints in f1.__rules[0].constraintsList, true)
        nools.deleteFlow(f1)

    describe "satisfies function", ->
      it "should return true if the fact satisfy the constraint", ->
        f1 = nools.compile('./rule.nools')
        Machine = f1.getDefined('machine')
        m = new Machine('Type1')
        fact = {object : m}
        assert(f1.satisfies(f1.__rules[0].pattern.constraints, fact), true)
        nools.deleteFlow(f1)

      it "should return false if the fact does not satisfies the constraints", ->
        f1 = nools.compile('./rule.nools')
        Machine = f1.getDefined('machine')
        m = new Machine('Type2')
        fact = {object : m}
        assert.equal(f1.satisfies(f1.__rules[0].pattern.constraints, fact), false)
        nools.deleteFlow(f1)

    describe "match function", ->
      it "should execute the actions of rules whose constraints are satisfied", ->
        f1 = nools.compile('./rule.nools')
        Machine = f1.getDefined('machine')
        m1 = new Machine('Type2', 'DNS Server')
        m2 = new Machine('Type2', 'Gateway')
        f1.assert(m1)
        f1.assert(m2)
        f1.match()
        assert.deepEqual(m1.testsList, [ { id: 5 }, { id: 4 } ])
        assert.equal(m1.message, 'Rule Type2 DNS server applied')
        assert.deepEqual(m2.testsList, [ { id: 3 }, { id: 4 } ])
        assert.equal(m2.message, 'Rule Type2 Gatewayapplied')
        nools.deleteFlow(f1)




