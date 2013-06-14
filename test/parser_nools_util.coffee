assert = require('assert')
util = require('../src/parser/nools/util.coffee')
should = require('should')

describe "Parsing Utility Test - ", ->
  describe "getTokensBetween Function", ->

    it "should throw an error when the both the terminal tokens are not present", ->
      ( -> util.getTokensBetween("lorem(ipsum)lorem[ipsum]", "{", "}")).should.throw "Unable to match { in lorem(ipsum)lorem[ipsum]"
      ( -> util.getTokensBetween("lorem{ipsum}lorem(ipsum)", "[", "]")).should.throw "Unable to match [ in lorem{ipsum}lorem(ipsum)"

    it "should throw an error when only the starting terminal token is present", ->
      ( -> util.getTokensBetween("lorem{ipsum)lorem[ipsum]", "{", "}")).should.throw "Unable to match { in lorem{ipsum)lorem[ipsum]"
    
    it "should throw an error when only the ending terminal token is present", ->
      ( -> util.getTokensBetween("lorem(ipsum}lorem[ipsum]", "{", "}")).should.throw "Unable to match { in lorem(ipsum}lorem[ipsum]"

    describe "when both the terminal tokens are present", ->

      it "should return empty list when nothing is present in the start and end tokens", ->
        assert.equal(0, util.getTokensBetween("{}", '{', '}').length)
        assert.equal(0, util.getTokensBetween("loremipsum{}loremipsum", '{', '}').length)

      describe "when there is wrong nesting of terminal tokens", ->
        
        it "should throw an error when more start tokens than end tokens are present", ->
          ( -> util.getTokensBetween("lorem{ipsum{loremipsum}lorem[ipsum]", "{", "}")).should.throw "Unable to match { in lorem{ipsum{loremipsum}lorem[ipsum]"

        describe "when start and end tokens are included", ->
        
          it "should return the content between matching end token when more end tokens than start tokens are present", ->
            assert.deepEqual(util.getTokensBetween("lorem{ipsumlorem}ipsum}lorem[ipsum]", "{", "}", true), ['{','i','p','s','u','m','l','o','r','e','m','}'])
            assert.deepEqual(util.getTokensBetween("(lorem(ipsum)lorem)ipsum)lorem[ipsum]", "(", ")", true), ['(','l','o','r','e','m','(','i','p','s','u','m',')','l','o','r','e','m',')'])

        describe "when start and end tokens are not included", ->
        
          it "should return the content between matching end token when more end tokens than start tokens are present", ->
            assert.deepEqual(util.getTokensBetween("lorem{ipsumlorem}ipsum}lorem[ipsum]", "{", "}"), ['i','p','s','u','m','l','o','r','e','m'])
            assert.deepEqual(util.getTokensBetween("(lorem(ipsum)lorem)ipsum)lorem[ipsum]", "(", ")"), ['l','o','r','e','m','(','i','p','s','u','m',')','l','o','r','e','m'])


      describe "when there is proper nesting of terminal tokens", ->

        describe "when start and end tokens are included", ->

          it "should return the content between matching start and end tokens", ->
            assert.deepEqual(util.getTokensBetween("{lorem{ipsum(lorem)ipsum}[lorem}][ipsum]", "{", "}", true), ['{','l','o','r','e','m','{','i','p','s','u','m','(','l','o','r','e','m',')','i','p','s','u','m','}','[','l','o','r','e','m','}'])

        describe "when start and end tokens are not included", ->

          it "should return the content between matching start and end tokens", ->
            assert.deepEqual(util.getTokensBetween("{lorem{ipsum(lorem)ipsum}[lorem}][ipsum]", "{", "}"), ['l','o','r','e','m','{','i','p','s','u','m','(','l','o','r','e','m',')','i','p','s','u','m','}','[','l','o','r','e','m'])
    
    describe "when custom error message is present", ->

      it "should throw the custom error if any error occurs", ->
        ( -> util.getTokensBetween("lorem{ipsum{loremipsum}lorem[ipsum]", "{", "}", false, "Custom Error")).should.throw "Custom Error"

  describe "getParamList Function", ->

    it "should throw an error when both the parentheses are not present", ->
      ( -> util.getParamList("lorem{ipsum}lorem[ipsum]")).should.throw "Unable to match ( in lorem{ipsum}lorem[ipsum]"


    it "should throw an error when only the starting parentheses is present", ->
      ( -> util.getParamList("lorem(ipsum}lorem[ipsum]")).should.throw "Unable to match ( in lorem(ipsum}lorem[ipsum]"
    
    it "should throw an error when only the ending parentheses is present", ->
      ( -> util.getParamList("lorem{ipsum)lorem[ipsum]")).should.throw "Unable to match ( in lorem{ipsum)lorem[ipsum]"

    it "should return the paremeter list when both the parentheses are present", ->
      assert.equal(util.getParamList("function(lorem, ipsum = true)"), "(lorem, ipsum = true)")
      assert.equal(util.getParamList("function(lorem, ipsum = [], lorem = {})"), "(lorem, ipsum = [], lorem = {})")

  describe "findNextTokenIndex Function", ->
    it "should return -1 when all whitespace characters are present between start and end indices", ->
      assert.equal(util.findNextTokenIndex('     \r   \n \t     '), -1)
      assert.equal(util.findNextTokenIndex('lorem\r\n\t         ipsum', 5, 11), -1)
      assert.equal(util.findNextTokenIndex('lorem\r\n\t         ', 5, 11), -1)
      assert.equal(util.findNextTokenIndex('\r\n\t         ipsum', 5, 11), -1)

    it "should return index of the first non whitespace character present between the start and end indices", ->
      assert.equal(util.findNextTokenIndex('     lorem ipsum'), 5)
      assert.equal(util.findNextTokenIndex('     lorem       ipsum', 12), 17)

  describe "findNextToken Function", ->
    it "should return undefined when all whitespace characters are present between start and end indices", ->
      assert.equal(util.findNextToken('     \r   \n \t     '), "")
      assert.equal(util.findNextToken('lorem\r\n\t         ipsum', 5, 11), "")
      assert.equal(util.findNextToken('lorem\r\n\t         ', 5, 11), "")
      assert.equal(util.findNextToken('\r\n\t         ipsum', 5, 11), "")

    it "should return the first non whitespace character present between the start and end indices", ->
      assert.equal(util.findNextToken('     lorem ipsum'), 'l')
      assert.equal(util.findNextToken('     lorem       ipsum', 12), 'i')
