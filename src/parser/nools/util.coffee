###

Defines utility functions for parsing

  function getTokensBetween(str, start, stop, includeStartEnd) --> list
    str             --> string to parse
    start           --> start token
    stop            --> stop token
    includeStartEnd --> whether to include start and stop tokens in the return list
  returns list  of characters between start and stop tokens

  function getParamList(str) --> string
    str   --> string to parse
  returns parameters of a function as a string

  function findNextTokenIndex(str, startIndex, endIndex) --> integer
    str         --> string to parse
    startIndex  --> index from where to start parsing
    endIndex    --> index where parsing should stop
  returns index of first non-whitespace character in the string str between [start index, end index)

  function findNextToken(str, startIndex, endIndex) --> character
    str   -->string to parse
    startIndex  --> index from where to start parsing
    endIndex    --> index where parsing should stop
  returns first non-whitespace character in the string str between [start index, end index)

###


"use strict"

WHITE_SPACE_REG = /[\s|\n|\r|\t]/

TOKEN_INVERTS = 
  '{' : '}'
  '}' : '{'
  '(' : ')'
  ')' : '('
  '[' : ']'

getTokensBetween = exports.getTokensBetween = (str, start, stop, includeStartEnd, customError) ->
  depth = 0
  ret = []

  if not start                                              # check the not operator
    start = TOKEN_INVERTS[stop]
    depth = 1

  stop or= TOKEN_INVERTS[start]                             # check the #= operator

  str = Object(str)
  startPushing = false
  cursor = 0
  found = false

  while token = str.charAt(cursor++)
    if token is start
      depth++
      if not startPushing
        startPushing = true
        ret.push(token) if includeStartEnd                # can be pushed outside the if condition
      else
        ret.push(token)
    else if (token is stop) and cursor
        depth--
        if depth is 0
          ret.push(token) if includeStartEnd
          found = true
          break
        ret.push(token)
    else if startPushing then ret.push(token)    
  
  if not found
    throw new Error(if customError then customError else "Unable to match #{start} in #{str}")

  return ret

exports.getParamList = (str, customError) -> 
  getTokensBetween(str, "(", ")", true, customError).join("")

findNextTokenIndex = exports.findNextTokenIndex = (str, startIndex, endIndex) ->
  startIndex or= 0
  l = str.length
  endIndex or= l
  ret = -1

  endIndex = l if (not endIndex) or (endIndex > l)
  while (startIndex < endIndex)
    if not WHITE_SPACE_REG.test(str.charAt(startIndex))
      ret = startIndex;
      break;
    startIndex++
  return ret

exports.findNextToken = (str, startIndex, endIndex) -> 
  str.charAt(findNextTokenIndex(str, startIndex, endIndex))
