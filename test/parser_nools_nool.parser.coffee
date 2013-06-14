assert = require('assert')
parser = require('../src/parser/nools/nool.parser.coffee')
should = require('should')

describe "Parsing Functions Wrapper -", ->
  describe "parse function", ->
    context = {}

    beforeEach( ->
      context.define = []
      context.rules = []
      context.scope = []
    )

    it "should throw an error if the string doesn't starts with one of the keywords('/', 'define', 'global', 'rule', 'function')", ->
      wrongStarting = "lorem ipsum lorem ipsum define Message {message : ''}"
      (-> parser.parse(wrongStarting)).should.throw "No keyword to start a block or declaration (one of the following \"/,define,global,function,rule\") found starting from\n#{wrongStarting}"

    it "should throw an error if define block is not proper", ->
      wrongDefine = ["define { m : '' } ", "global x = 5; ", "function f() { return true;} ", "rule r { when{ } then{ }}"]
      (-> parser.parse(wrongDefine.join(""))).should.throw "Invalid 'define' definition\nError message: Define block should have a name starting with an alphabet or dollar or underscore in:\n#{wrongDefine.join("")}"

    it "should throw an error if global declaration is not proper", ->
      wrongGlobal = ["define Message { m : '' } ", "global  = 5; ", "function f() { return true;} ", "rule r { when{ } then{ }}"]
      (-> parser.parse(wrongGlobal.join(""))).should.throw "Invalid 'global' definition\nError message: Global declarations should have a variable name starting with an alphabet or dollar or underscore in:\n#{wrongGlobal[1..].join("")}"

    it "should throw an error if function declaration is not proper", ->
      wrongFunction = ["define Message { m : '' } ", "global x = 5; ", "function () { return true;} ", "rule r { when{ } then{ }}"]
      (-> parser.parse(wrongFunction.join(""))).should.throw "Invalid 'function' definition\nError message: Function declaration should have a function name starting with an alphabet or dollar or underscore in:\n#{wrongFunction[2..].join("")}"

    describe "when there is error in rule declaration", ->

      describe "when cehcking for error in salience expression", ->

        it "should throw an error if there is no semicolon after 'salience/priority' keyword", ->
          (-> parser.parse("rule r{ salience 5;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'salience' definition\nError message: Salience expression should have a colon after the keyword 'salience' or 'priority'/

        it "should throw an error if there is wrong value given for salience/priority", ->
          (-> parser.parse("rule r{ salience : abc;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'salience' definition\nError message: Salience expression should have an integral salience value\(possibly negative\) after the colon/

        it "should throw an error if there is no value given for salience/priority", ->
          (-> parser.parse("rule r{ salience : ;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'salience' definition\nError message: Salience expression should have an integral salience value\(possibly negative\) after the colon/

      describe "when salience expression is correct", ->

        it "should update the context object to reflect salience value", ->
          context = parser.parse("rule r{ salience : -3;}", context)
          assert.equal(context.rules[0].options.priority, -3)


      describe "when there is error in agendagroup definition", ->

        it "should throw an error if there no colon after the 'agendaGroup/agenda-group' keyword", ->
          (-> parser.parse("rule r{agendaGroup 'ag1';}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'agendaGroup' definition\nError message: Agenda Group expression should have a colon after the keyword 'agenda-group' or 'agendaGroup'/

        it "should throw an error if there in no value given for agendagroup", ->
          (-> parser.parse("rule r{agendaGroup : ;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'agendaGroup' definition\nError message: Name of the agenda group should start with an alphabet or dollar or underscore or it should be written in single or double quotes/

        it "should throw an error if wrong format name is given for agendagroup", ->
          (-> parser.parse ("rule r{agendaGroup : #ag;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'agendaGroup' definition\nError message: Name of the agenda group should start with an alphabet or dollar or underscore or it should be written in single or double quotes/
          (-> parser.parse ("rule r{agendaGroup : '#ag;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'agendaGroup' definition\nError message: Name of the agenda group should start with a single quote should end with a single quote/
          (-> parser.parse ("rule r{agendaGroup : \"#ag;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'agendaGroup' definition\nError message: Name of the agenda group should start with a double quote should end with a double quote/

      describe "when the agendagroup expression is correct", ->

        it "should update the context object to reflect the agendaGroup", ->
          context = parser.parse("rule r{agendaGroup : '#ag';}")
          assert.equal(context.rules[0].options.agendaGroup, '#ag')

      describe "when there is error in autofocus expression", ->

        it "should throw an error if there is no semicolon after the 'autoFocus/auto-focus' keyword", ->
          (-> parser.parse("rule r{ autoFocus true;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'autoFocus' definition\nError message: Auto focus expression should have a colon after the keyword 'auto-focus' or 'autoFocus'/

        it "should throw an error if no value is given for autofocus", ->
          (-> parser.parse("rule r{ autoFocus : ;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'autoFocus' definition\nError message: Auto focus expression should have 'true' or 'false' as value after the colon/

        it "should throw an error if wrong value is given for autofocus", ->
          (-> parser.parse("rule r{ autoFocus : loremIpsum ;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'autoFocus' definition\nError message: Auto focus expression should have 'true' or 'false' as value after the colon/          
          (-> parser.parse("rule r{ autoFocus : 0 ;}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'autoFocus' definition\nError message: Auto focus expression should have 'true' or 'false' as value after the colon/          

      describe "when the autofocus expression is correct", ->
        it "should update the context object to reflect the autofocus option", ->
          context = parser.parse("rule r{ autoFocus : true ;}", context)
          assert.equal(context.rules[0].options.autoFocus, true)

      describe "when the when block expression is wrong", ->

        it "should throw an error if 'when' keyword is not followed by an opening curly bracket", ->
          (-> parser.parse("rule r{when  m : Message; r : Result }}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'when' definition\nError message: Unexpected token "m" while beginning When block \(after the 'when' keyword\) of 'Rule r'. When block should have an opening curly bracket '{' after the 'when' keyword/

        it "should throw an error if no closing curly bracket is present corresponding to the opening curly bracket of when block", ->
          (-> parser.parse("rule r{when { m : Message; r : Result }")).should.throw /^Invalid 'rule' definition\nError message: No closing curly bracket '}' found in Rule block of rule 'r'./

        it "should throw an error if no alias is present in a constraint", ->
          (-> parser.parse("rule r{when{ m : Message; #r : Result }}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'when' definition\nError message: Alias in rule condition should start with a word character or a dollar followed by any combination of zero or more word characters/

        it "should throw an error if any alias in rule definition starts with a character other than a word character or a dollar", ->
          (-> parser.parse("rule r{when{ m : Message;  : Result }}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'when' definition\nError message: Alias in rule condition should start with a word character or a dollar followed by any combination of zero or more word characters/

        it "should throw an error if colon is not present after the alias in a constraint", ->
          (-> parser.parse("rule r{when{ m : Message;  r Result }}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'when' definition\nError message: Rule condition should have a colon after the alias/          

        it "should throw an error if nothing is present after the colon in constraint", ->
          (-> parser.parse("rule r{when{ m : ;  r : Result }}")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'when' definition\nError message: The colon in rule condition should have any combination of one or more word characters after it/ 

      describe "when the when block is correct", ->

        it "should update the context object to reflect the constraints", ->
          context = parser.parse("rule r{when{ m : Message m.message =! /^hello/ ;  r : Result }}", context)
          assert.deepEqual(context.rules[0].constraints[0], ['Message','m','m.message =! /^hello/'])
          assert.deepEqual(context.rules[0].constraints[1], ['Result','r'])

      describe "when the then block expression is wrong", ->

        it "should throw an error if 'then' keyword is not followed by an opening curly bracket", ->
          (-> parser.parse("rule r{then console.log('lorem ipsum'); } }")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'then' definition\nError message: Unexpected token "c" while beginning Then block \(after the 'then' keyword\) of 'Rule r'. Then block should have an opening curly bracket '{' after the 'then' keyword/

        it "should throw an error if there is no closing curly bracket corrsponding to the opening curly bracket of then block", ->
          (-> parser.parse("rule r{then { console.log('lorem ipsum');  }")).should.throw /^Invalid 'rule' definition\nError message: No closing curly bracket '}' found in Rule block of rule 'r'/

        it "should throw an error if there is something left in the rule definition after parsing the then block", ->
          (-> parser.parse("rule r{then { console.log('lorem ipsum'); } lorem ipsum }")).should.throw /^Invalid 'rule' definition\nError message: Invalid 'then' definition\nError message: Error parsing then block. There should be nothing in the rule body after then block:/

        it "should throw an error if action for the rule has already been defined"

      describe "when the then block is correct", ->

        it "should update the context object to reflect the actions", ->
          context = parser.parse("rule r{then { console.log('lorem ipsum');}  }", context)
          assert.equal(context.rules[0].action, 'console.log(\'lorem ipsum\');')

    describe "when the rule declaration is correct", ->
      it "should update the context object to reflect the rule", ->
        context = parser.parse("rule r{ when {m : Message m.message =~ /^hello/} then {console.log('lorem ipsum');}}", context)
        assert.deepEqual(context.rules[0], {
          name : 'r'
          options : {}
          constraints : [['Message','m','m.message =~ /^hello/']]
          action: 'console.log(\'lorem ipsum\');'
         })

    describe "when the rule source is correct", ->
      it "should update the context object to reflect the rule source", ->
        context = parser.parse("/*This is a comment*/ define Message {m : ''} function f(a,b) {return true;} global x = 5; rule r {}", context)
        assert.deepEqual(context, { 
          define: 
            [ {
              name: 'Message'
              properties: '({m : \'\'})' 
            } ]
          rules: 
            [ { 
              name: 'r'
              options: {}
              constraints: null
              action: null
            } ]
          scope: 
            [ { 
                name: 'f',
                body: 'function(a,b){return true;}' 
              }
              { 
                name: 'x', body: '5' 
              } ]
        })
