###
  Defines function for parsing DSL 

  function parse(src, keywords, context) -->  Nothing
    src       --> string containing DSL text
    keywords  --> hash of types of blocks as key and functions to parse those blocks as corresponding values
    context   --> hash to store context information about rules
  returns nothing

  function parse(src)  --> Hash
    src --> string containing DSL text
  returns a hash containing context information about rules

###

"use strict"

tokens = require('./tokens')
keys = require('../../extended').hash.keys
utils = require('./util')

parse = (src, keywords, context) ->
  orig = src
  src = src.replace(/\/\/(.*)[\n|\r|\r\n]/g, "").replace(/\n|\r|\r\n/g, " ")
  blockTypes = new RegExp("^(#{keys(keywords).join('|')})")
  while src and ((index = utils.findNextTokenIndex(src)) isnt -1)
    src = src.substr(index)
    blockType = src.match(blockTypes)
    if blockType?
      blockType = blockType[1]
      if blockType of keywords                                                                    # This condition may not be required since this may be checked in the regex only..  
        try
          src = keywords[blockType](src, context, parse).replace(/^\s*|\s*$/g, "")
        catch e
          throw new Error("Invalid '#{blockType}' definition\nError message: #{e.message}")
      else
        throw new Error("Unknown token '#{blockType}' found. Tokens can be one of the following \"#{keys(keywords).join(',')}\". Code:\n#{src}")
    else
      throw new Error("No keyword to start a block or declaration (one of the following \"#{keys(keywords).join(',')}\") found starting from\n#{src}")

exports.parse = (src) ->
  context = 
    define : []
    rules : []
    scope : []
  parse(src, tokens, context)
  return context
