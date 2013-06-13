###

Defines function for tokenizing salience, agendaGroup, autoFocus, agenda-group, auto-focus, priority parameters and global variables. Also it defines functions for parsing when, then, define, function and rule blocks and removing block comments.

  function isWhiteSpace(str) --> Boolean
    str --> string to check whitespace characters
  return true the string contains only whitespace characters, otherwise returns false
  
  function salience() --> function(src, context)
  returns a function which takes salience string and context parameter and changes the priority in the context parameter by parsing the salience string.

  function agendaGroup() --> function(src, context)
  returns a function which takes agendaGroup string and context parameter and changes the agenda group in the context parameter by parsing the agendaGroup string.
  
  function autoFocus() --> function(src, context)
  returns a function which takes autoFocus string and context parameter and changes the autofocus in the context parameter by parsing the autoFocus string.

  function agenda-group() --> function(src, context)
  Call agendaGroup function

  function auto-focus() --> function(src, context)
  Call autoFocus function

  function priority() --> function(src, context)
  Call salience function

  function parseRules(str) --> List
    str --> the string to be parsed for conditions
  returns a list of conditions after parsing text in str

  function when() --> function(orig, context)
  returns a function which takes the orig string and parses it for when block and changes constraints in context parameter

  function then() --> function(orig, context)
  returns a function which takes the orig string and parses it for then block and change the action in the context parameter

  function /(orig) --> String
    orig  --> string
  return a new string after removing block comments from orig

  function define(orig, context)  --> String
    orig    --> string
    context --> hash containing context parameters
  returns a new string after removing define block from it and update the define list in the context parameter

  function global(orig, context) --> String
    orig    --> string
    context --> hash containing context parameters
  returns a new string after removing global definition from it and update the scope list in the context parameter
  
  function function(orig, context) --> String
    orig    --> string
    context --> hash containing context parameters
  returns a new string after removing function definition and body from it and update the scope list in the context parameter

  function rule(orig, context) --> String
    orig    --> string
    context --> hash containing context parameters
  returns a new string after removing rule block from it and update the rules list in the context parameter

###

"use strict"

utils = require("./util")

isWhiteSpace = (str) -> str.replace(/[\s|\n|\r|\t]/g, "").length is 0

ruleTokens = 
  salience : do ->
    salienceRegexp = /^(salience|priority)\s*:\s*(-?\d+)\s*[,;]?/
    (src, context) ->
      if salienceRegexp.test(src)
        parts = src.match(salienceRegexp)
        priority = parseInt(parts[2], 10)
        if not isNaN(priority)
          context.options.priority = priority
        else
          throw new Error("Invalid salience/priority value #{parts[2]}")
        src.replace(parts[0], "")
      else
        srcCopy = new String(src)
        orig = new String(src)
        matchedLength = 0
        salienceRegexpParts = [
          {
            partRegexp : /^(salience|priority)\s*/
            errMesg : "Salience expression should begin with the keyword 'salience' or 'priority'"
          }
          {
            partRegexp : /^:\s*/
            errMesg : "Salience expression should have a colon after the keyword 'salience' or 'priority'"
          }
          {
            partRegexp : /^(-?\d+)\s*/
            errMesg : "Salience expression should have an integral salience value(possibly negative) after the colon"
          }
        ]
        for part in salienceRegexpParts
          if part.partRegexp.test(srcCopy)
            match = srcCopy.match(part.partRegexp)
            srcCopy = srcCopy.replace(match[0], "")
            matchedLength += match[0].length
          else
            throw new Error(part.errMesg + "\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")

  agendaGroup : do ->
    agendaGroupRegexp = /^(agenda-group|agendaGroup)\s*:\s*([a-zA-Z_$][0-9a-zA-Z_$]*|"[^"]*"|'[^']*')\s*[,;]?/
    (src, context) ->
      if agendaGroupRegexp.test(src)
        parts = src.match(agendaGroupRegexp)
        agendaGroup = parts[2]
        if agendaGroup
          context.options.agendaGroup = agendaGroup.replace(/^["']|["']$/g, "")
        else
          throw new Error("Invalid agenda-group #{parts[2]}")
        src.replace(parts[0], "")
      else
        srcCopy = new String(src)
        orig = new String(src)
        matchedLength = 0
        agendaGroupRegexpParts = [
          {
            partRegexp : /^(agenda-group|agendaGroup)\s*/
            errMesg : "Agenda Group expression should begin with the keyword 'agenda-group' or 'agendaGroup'"
          }
          {
            partRegexp : /^:\s*/
            errMesg : "Agenda Group expression should have a colon after the keyword 'agenda-group' or 'agendaGroup'"
          }
        ]
        for part in agendaGroupRegexpParts
          if part.partRegexp.test(srcCopy)
            match = srcCopy.match(part.partRegexp)
            srcCopy = srcCopy.replace(match[0], "")
            matchedLength += match[0].length
          else 
            throw new Error(part.errMesg + "\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")
        
        # Code to check format of name of agenda
        nameBeginRegexp = /^[a-zA-Z_$]|"|'/
        if nameBeginRegexp.test(srcCopy)
          match = srcCopy.match(nameBeginRegexp)
          srcCopy = srcCopy.replace(match[0], "")
          matchedLength += match[0]
          if match[0] is "\""
            nameRestRegexp = /^[^"]"\s*/
            if not nameRestRegexp.test(srcCopy)
              throw new Error("Name of the agenda group should start with a double quote should end with a double quote\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")
          else if match[0] is "\'"
            nameRestRegexp = /^[^']'\s*/
            if not nameRestRegexp.test(srcCopy)
              throw new Error("Name of the agenda group should start with a single quote should end with a single quote\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")
        else
          throw new Error("Name of the agenda group should start with an alphabet or dollar or underscore or it should be written in single or double quotes\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")

  autoFocus: do  ->
    autoFocusRegexp = /^(auto-focus|autoFocus)\s*:\s*(true|false)\s*[,;]?/
    (src, context) ->
      if autoFocusRegexp.test(src)
        parts = src.match(autoFocusRegexp)
        autoFocus = parts[2]
        if autoFocus
          context.options.autoFocus = (if autoFocus is "true" then true else false)
        else
          throw new Error("Invalid auto-focus value : #{parts[2]}")             # may not be necessary. we are checking for true or false value in regexp itself
        src.replace(parts[0], "")
      else
        srcCopy = new String(src)
        orig = new String(src)
        matchedLength = 0
        autoFocusRegexpParts = [
          {
            partRegexp : /^(auto-focus|autoFocus)\s*/
            errMesg : "Auto focus expression should begin with the keyword 'auto-focus' or 'autoFocus'"
          }
          {
            partRegexp : /^:\s*/
            errMesg : "Auto focus expression should have a colon after the keyword 'auto-focus' or 'autoFocus'"
          }
          {
            partRegexp : /^(true|false)\s*/
            errMesg : "Auto focus expression should have 'true' or 'false' as value after the colon"
          }
        ]
        for part in autoFocusRegexpParts
          if part.partRegexp.test(srcCopy)
            match = srcCopy.match(part.partRegexp)
            srcCopy = srcCopy.replace(match[0], "")
            matchedLength += match[0].length
          else 
            throw new Error(part.errMesg + "\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")

# Try to correct this part. Giving some errors while compiling with coffee

#  "agenda-group" : @agendaGroup.apply(this, arguments)

#  "auto-focus" : @autoFocus.apply(this, arguments)

#  "priority" : @salience.apply(this, arguments)

  when : do ->
    ruleRegExp = /^(\$?\w+) *: *(\w+)(.*)/
    joinFunc = (m, str) -> "; #{str}"
    constraintRegExp =  /(\{(?:["']?\$?\w+["']?\s*:\s*["']?\$?\w+["']? *(?:, *["']?\$?\w+["']?\s*:\s*["']?\$?\w+["']?)*)+\})/
    predicateExp = /^(\w+) *\((.*)\)$/m
    parseRules = (str) ->
      rules = []
      ruleLines = str.split(";")
      for ruleLine in ruleLines
        ruleLine = ruleLine.replace(/^\s*|\s*$/g, "").replace(/\n/g, "")
        if not isWhiteSpace(ruleLine)
          rule = []
          if predicateExp.test(ruleLine)
            m = ruleLine.match(predicateExp)
            pred = m[1].replace(/^\s*|\s*$/g, "")
            rule.push(pred)
            ruleLine = m[2].replace(/^\s*|\s*$/g, "")
            if pred is "or"
              rule = rule.concat(parseRules(ruleLine.replace(/,\s*(\$?\w+\s*:)/, joinFunc)))
              rules.push(rule)
              continue
          parts = ruleLine.match(ruleRegExp)
          if parts and parts.length
            rule.push(parts[2], parts[1])
            constraints = parts[3].replace(/^\s*|\s*$/g, "")
            hashParts = constraints.match(constraintRegExp)
            if (hashParts)
              hash = hashParts[1]
              constraint = constraints.replace(hash, "")
              if constraint then rule.push(constraint.replace(/^\s*|\s*$/g, ""))
              if hash then rule.push(eval("(${hash.replace(/(\$?\w+)\s*:\s*(\$?\w+)/g, '\"$1\" : \"$2\"')})"))
            else if constraints and not isWhiteSpace(constraints)
              rule.push(constraints)
            rules.push(rule)
          else
            srcCopy = new String(ruleLine)
            orig = new String(str)
            matchedLength = 0
            ruleRegExpParts = [
              {
                partRegexp : /^(\$?\w+) */
                errMesg : "Alias in rule condition should start with a word character or a dollar followed by any combination of zero or more word characters"
              }
              {
                partRegexp : /^: */
                errMesg : "Rule condition should have a colon after the alias"
              }
              {
                partRegexp : /^(\w+)/
                errMesg : "The colon in rule condition should have any combination of one or more word characters after it"
              }
            ]
            for part in ruleRegExpParts
              if part.partRegexp.test(srcCopy)
                match = srcCopy.match(part.partRegexp)
                srcCopy = srcCopy.replace(match[0], "")
                matchedLength += match[0].length
              else
                throw new Error(part.errMesg + "\n" + orig + "\n" + (new Array(matchedLength + 1)).join(" ") + "^\n")
      return rules

    (orig, context) ->
      src = orig.replace(/^when\s*/, "").replace(/^\s*|\s*$/g, "")
      if utils.findNextToken(src) is "{"
        body = utils.getTokensBetween(src, "{", "}", true, "No closing curly bracket '}' found in When block of 'Rule #{context.name}'. Code:\n#{orig}").join("")
        src = src.replace(body, "")
        context.constraints = parseRules(body.replace(/^\{\s*|\}\s*$/g, ""))
        return src
      else
        throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" while beginning When block (after the 'when' keyword) of 'Rule #{context.name}'. When block should have an opening curly bracket '{' after the 'when' keyword")

  then : do ->
    (orig, context) ->
      if not context.action
        src = orig.replace(/^then\s*/, "").replace(/^\s*|\s*$/g, "")
        if utils.findNextToken(src) is "{"
          body = utils.getTokensBetween(src, "{", "}", true, "No closing curly bracket '}' found in Then block of 'Rule #{context.name}'. Code:\n#{orig}").join("")
          src = src.replace(body, "")
          context.action = body.replace(/^\{\s*|\}\s*$/g, "")                 # if condition in original code wasn't necessary
          if not isWhiteSpace(src) then throw new Error("Error parsing then block. There should be nothing in the rule body after then block:\n #{orig}")          # check the error message in pipes
          return src
        else
          throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" while beginning Then block (after the 'then' keyword) of 'Rule #{context.name}'. Then block should have an opening curly bracket '{' after the 'then' keyword")
      else 
        throw new Error("Action already defined for rule #{context.name}")

module.exports = 
  "/" : (orig) -> if orig.match(/^\/\*/) then orig.replace(/\/\*.*?\*\//, "") else return orig
  define : (orig, context) ->
    src = orig.replace(/^define\s*/, "")
    name = src.match(/^([a-zA-Z_$][0-9a-zA-Z_$]*)/)
    if name
      src = src.replace(name[0], "").replace(/^\s*|\s*$/g, "")
      if utils.findNextToken(src) is "{"
        name = name[1]
        body = utils.getTokensBetween(src, "{", "}", true,"No closing curly bracket '}' found in define block while defining '#{name}'. Code:\n#{orig}").join("")
        src = src.replace(body, "")
        context.define.push({name : name, properties: "(#{body})"})
        return src                          # can be removed with the statement above the above statement
      else
        throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" while beginning Define block (after the name of define block) of 'Define block #{name[1]}'. Define block should have an opening curly bracket '{' after the name of define block")
    else 
      throw new Error("Define block should have a name starting with an alphabet or dollar or underscore in:\n#{orig}")


  global : (orig, context) ->
    src = orig.replace(/^global\s*/, "")
    name = src.match(/^([a-zA-Z_$][0-9a-zA-Z_$]*\s*)/)
    if name
      src = src.replace(name[0], "").replace(/^\s*|\s*$/g, "")
      if utils.findNextToken(src) is "="
        name = name[1].replace(/^\s+|\s+$/g, '')
        fullbody = utils.getTokensBetween(src, '=', ';', true, "No semicolon ';' found while declaring global variable '#{name}'. Code:\n#{orig}").join("")
        body = fullbody.substring(1, fullbody.length - 1).replace(/^\s+|\s+$/g, '')         # this and above statement can be replaced with a single statement
        context.scope.push({name: name, body: body})
        src = src.replace(fullbody, "")
      else 
        throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" in global declaration (after the name of variable) of 'Global variable #{name[1].replace(/^\s+|\s+$/g, '')}'. Global declarations should have an equals sign '=' after the name of the variable")
    else
      throw new Error("Global declarations should have a variable name starting with an alphabet or dollar or underscore in:\n#{orig}")

  function : (orig, context) ->
    src = orig.replace(/^function\s*/, "")
    name = src.match(/^([a-zA-Z_$][0-9a-zA-Z_$]*)\s*/)
    if name
      src = src.replace(name[0], "")
      if utils.findNextToken(src) is "("
        name = name[1]
        params = utils.getParamList(src, "No closing parentheses ')' found for arguments list of function '#{name}'. Code:\n#{orig}")
        src = src.replace(params, "").replace(/^\s*|\s*$/g, "")
        if utils.findNextToken(src) is "{"
          body = utils.getTokensBetween(src, "{", "}", true, "No closing curly bracket '}' found in function declaration of function '#{name}'. Code:\n#{orig}").join("")
          src = src.replace(body, "")
          context.scope.push({name: name, body: "function#{params}#{body}"})
          return src 
        else
          throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" in function declaration (after the closing parentheses of arguments list) of 'Function #{name}'. Function declarations should have an opening curly bracket '{' after the closing parentheses of argument list")
      else 
        throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" in function declaration (after name of the function) of 'Function #{name[1]}'. Function declarations should have an opening parentheses '(' after the function name")
    else 
      throw new Error("Function declaration should have a function name starting with an alphabet or dollar or underscore in:\n#{orig}")

  rule : (orig, context, parse) ->
    src = orig.replace(/^rule\s*/, "")
    name = src.match(/^([a-zA-Z_$][0-9a-zA-Z_$]*|"[^"]*"|'[^']*')/)
    if name
      src = src.replace(name[0], "").replace(/^\s*|\s*$/g, "")
      if utils.findNextToken(src) is "{"
        name = name[1].replace(/^["']|["']$/g, "")
        rule = 
          name: name
          options: {}
          constraints: null
          action: null
        body = utils.getTokensBetween(src, "{", "}", true, "No closing curly bracket '}' found in Rule block of rule '#{name}'. Code:\n#{orig}").join("")
        src = src.replace(body, "")
        parse(body.replace(/^\{\s*|\}\s*$/g, ""), ruleTokens, rule)
        context.rules.push(rule)
        return src
      else
        throw new Error("Unexpected token \"#{utils.findNextToken(src)}\" while beginning Rule block (after name of the rule) of 'Rule #{name[1].replace(/^["']|["']$/g, "")}'. Rule block should have an opening curly bracket '{' after name of the rule")
    else
      srcCopy = new String(src)
      # Code to check the name of the rule
      nameBeginRegexp = /^([a-zA-Z_$|"|'])/
      if (nameBeginRegexp.test(srcCopy))
        match = srcCopy.match(nameBeginRegexp)
        srcCopy = srcCopy.replace(match[0], "")
        if match[0] is "\""
          nameRestRegexp = /^[^"]"\s*/
          if not nameRestRegexp.test(srcCopy)
            throw new Error("Name of the Rule block should start with a double quote should end with a double quote in rule\n" + orig)
        else if match[0] is "\'"
          nameRestRegexp = /^[^']'\s*/
          if not nameRestRegexp.test(srcCopy)
            throw new Error("Name of the Rule block should start with a single quote should end with a single quote\n" + orig)
      else 
        throw new Error("Rule block should have a name starting with an alphabet or dollar or underscore or enclosed in single or double quotes\n" + orig)
