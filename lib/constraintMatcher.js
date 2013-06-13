// Generated by CoffeeScript 1.6.2
/*

  Defines functions for converting constraints lists into javascript code

  definedFuncs --> maps function names to functions, most of which are already defined in extended libraries
    indexOf --> defined in array-extended package
    
    now() --> Date
    returns a date object representing current date and time

    Date(y, m, d, h, min, s, ms) -> Date
      y --> number representing year
      m --> number representing month
      d --> number representing date
      h --> number representing hour
      min --> number representing minute
      s --> number representing second
      ms --> number representing millisecond
    returns a date object representing the date and time provided as arguments

    lengthOf(arr, length) --> Boolean
      arr --> an array object
      length --> an integer
    returns true if size of array is equal to the length parameter, otherwise returns false

    isTrue(val) --> Boolean
      val --> Boolean value
    returns true if val paramter is a boolean true, otherwise returns false
    
    isFalse(val) --> Boolean
      val --> Boolean value
    returns true if val parameter is a boolean false, otherwise returns false

    isNotNull(actual) --> Boolean
      actual --> any identifier
    returns true if the identifier value is not null, otherwise returns false

    dateCmp(c1, c2) --> uses compare function defined in date-extended package

    Functions defined in date-extended                       
      yearsFromNow            
      daysFromNow             
      monthsFromNow           
      hoursFromNow            
      minutesFromNow          
      secondsFromNow          
      yearsAgo                
      daysAgo                 
      monthsAgo               
      hoursAgo                
      minutesAgo              
      secondsAgo

    Functions defined in is-extended
      isArray
      isNumber
      isHash
      isObject
      isDate
      isBoolean
      isString
      isRegExp
      isNull
      isEmpty
      isUndefined
      isDefined
      isUndefinedOrNull
      isPromiseLike
      isFunction
      deepEqual             
  
  lang --> define functions for operations in the define CFG to map the list obtained from CFG to javascript code + some other helper functions
    equal(c1,c2) --> Boolean
      c1 --> List representing expression
      c2 --> List representing expression
    returns true if c1 and c2 represent the same expression, otherwise returns false

    getIdentifiers(rule) --> List
      rule --> List representing expressions in a rule
    returns a list of identifiers in the expressions

    toConstraints(rule, options) --> List
      rule --> List representing expressions in a rule
      options --> ???
    returns a list of Constraint objects

    parse(rule) --> string
      rule --> rule --> List representing expressions in a rule
    returns a string representing a javascript expression for the rule

    composite(lhs) --> string
      lhs --> List representing a composite expression
    returns a string representing a javascript expression for the composite expression

    and(lhs, rhs) --> string
      lhs --> left hand expression list of the and operator
      rhs --> right hand expression list of the and operator
    returns a string representing a javascript expression for the and expression

    or(lhs, rhs) --> string
      lhs --> left hand expression list of the or operator
      rhs --> right hand expression list of the or operator
    returns a string representing a javascript expression for the or expression

    prop(name, prop) --> string
      name --> list representing the name expression of object
      prop --> list representing the property 
    returns a string representing a javascript expression for the property

    unminus(lhs) --> string
      lhs --> list representing the expression on which unary minus is applied
    returns a string expression representing the javascript expression for the unary minus operation

    plus(lhs, rhs) --> string
      lhs --> left hand expression list of the plus operator
      rhs --> right hand expression list of the plus operator
    returns a string representing a javascript expression for the plus expression

    minus(lhs, rhs) --> string
      lhs --> left hand expression list of the minus operator
      rhs --> right hand expression list of the minus operator
    returns a string representing a javascript expression for the minus expression

    mult(lhs, rhs) --> string
      lhs --> left hand expression list of the multiplication operator
      rhs --> right hand expression list of the multiplication operator
    returns a string representing a javascript expression for the multiplication expression

    div(lhs, rhs) --> string
      lhs --> left hand expression list of the division operator
      rhs --> right hand expression list of the division operator
    returns a string representing a javascript expression for the division expression

    mod(lhs, rhs) --> string
      lhs --> left hand expression list of the modulus operator
      rhs --> right hand expression list of the modulus operator
    returns a string representing a javascript expression for the modulus expression

    lt(lhs, rhs) --> string
      lhs --> left hand expression list of the less than operator
      rhs --> right hand expression list of the less than operator
    returns a string representing a javascript expression for the less than expression

    gt(lhs, rhs) --> string
      lhs --> left hand expression list of the greater than operator
      rhs --> right hand expression list of the greater than operator
    returns a string representing a javascript expression for the greater than expression

    lte(lhs, rhs) --> string
      lhs --> left hand expression list of the less than and equal operator
      rhs --> right hand expression list of the less than and equal operator
    returns a string representing a javascript expression for the less than and equal expression

    gte(lhs, rhs) --> string
      lhs --> left hand expression list of the greater than and equal operator
      rhs --> right hand expression list of the greater than and equal operator
    returns a string representing a javascript expression for the greater than and equal expression

    like(lhs, rhs) --> string
      lhs --> left hand expression list of the like operator
      rhs --> right hand expression list of the like operator(normally a regexp)
    returns a string representing a javascript expression for the like expression

    notLike(lhs, rhs) --> string
      lhs --> left hand expression list of the notLike operator
      rhs --> right hand expression list of the notLike operator(normally a regexp)
    returns a string representing a javascript expression for the notLike expression

    eq(lhs, rhs) --> string
      lhs --> left hand expression list of the equality operator
      rhs --> right hand expression list of the equality operator
    returns a string representing a javascript expression for the equality expression

    neq(lhs, rhs) --> string
      lhs --> left hand expression list of the inequality operator
      rhs --> right hand expression list of the inequality operator
    returns a string representing a javascript expression for the inequality expression

    in(lhs, rhs) --> string
      lhs --> left hand expression list of the in operator
      rhs --> right hand expression list of the in operator(normally an array)
    returns a string representing a javascript expression for the in expression

    notIn(lhs, rhs) --> string
      lhs --> left hand expression list of the notIn operator
      rhs --> right hand expression list of the notIn operator(normally an array)
    returns a string representing a javascript expression for the notIn expression

    arguments(lhs, rhs) --> string
      lhs --> list representing all but last arguments
      rhs --> list representing the last argument
    returns a string representing a javascript expression for the arguments

    array(lhs) --> string
      lhs --> list representing array elements
    returns a string representing a javascript expression for the array

    function(lhs, rhs) --> string
      lhs --> list representing the name of the function
      rhs --> list representing arguments to the function
    returns a string representing a javascript expression for the function declaration

    string(lhs) --> string
      lhs --> string
    returns single quoted lhs

    number(lhs) --> number
      lhs --> number
    returns number lhs

    boolean(lhs) --> boolean
      lhs --> boolean value
    returns boolean lhs

    regexp(lhs) --> regexp object
      lhs --> regular expression object
    returns regular expression object lhs

    identifier(lhs) --> string
      lhs --> string
    returns string lhs

    null() --> Null object
    returns a null object

    toJs(rule, scope) --> Function
      rule --> a nested list representing rule constraints
      scope  --> ???
    converts the rule list into javascript code and returns a function which given two dictionaries, executes the javascript code
    
    getMatcher(rule, scope) --> another alias for toJs

    toConstraints(constraint, options) --> another alias for lang.toConstraints
    
    equal(c1, c2) --> another alias for lang.equal

    getIdentifiers(constraint) --> another alias for lang.getIdentifiers
*/


(function() {
  "use strict";
  var atoms, definedFuncs, extd, forEach, indexOf, isArray, isNumber, k, lang, map, removeDups, some, toJs, _i, _len, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  extd = require('./extended');

  isArray = extd.isArray;

  forEach = extd.forEach;

  some = extd.some;

  map = extd.map;

  indexOf = extd.indexOf;

  isNumber = extd.isNumber;

  removeDups = extd.removeDuplicates;

  atoms = require('./constraint.coffee');

  definedFuncs = {
    indexOf: extd.indexOf,
    now: function() {
      return new Date();
    },
    Date: function(y, m, d, h, min, s, ms) {
      var date;

      date = new Date();
      if (isNumber(y)) {
        date.setYear(y);
      }
      if (isNumber(m)) {
        date.setMonth(m);
      }
      if (isNumber(d)) {
        date.setDate(d);
      }
      if (isNumber(h)) {
        date.setHours(h);
      }
      if (isNumber(min)) {
        date.setMinutes(min);
      }
      if (isNumber(s)) {
        date.setSeconds(s);
      }
      if (isNumber(ms)) {
        date.setMilliseconds(ms);
      }
      return date;
    },
    lengthOf: function(arr, length) {
      return arr.length === length;
    },
    isTrue: function(val) {
      return val === true;
    },
    isFalse: function(val) {
      return val === false;
    },
    isNotNull: function(actual) {
      return actual !== null;
    },
    dateCmp: function(d1, d2) {
      return extd.compare(d1, d2);
    }
  };

  _ref = ["years", "days", "months", "hours", "minutes", "seconds"];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    k = _ref[_i];
    definedFuncs[k + "FromNow"] = extd[k + "FromNow"];
    definedFuncs[k + "Ago"] = extd[k + "Ago"];
  }

  definedFuncs[k] = function() {
    var _j, _len1, _ref1, _results;

    _ref1 = ["isArray", "isNumber", "isHash", "isObject", "isDate", "isBoolean", "isString", "isRegExp", "isNull", "isEmpty", "isUndefined", "isDefined", "isUndefinedOrNull", "isPromiseLike", "isFunction", "deepEqual"];
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      k = _ref1[_j];
      _results.push(extd[k].apply(extd, arguments));
    }
    return _results;
  };

  lang = {
    equal: function(c1, c2) {
      var ret, _ref1;

      ret = false;
      if (c1 === c2) {
        return ret = true;
      } else {
        if (c1[2] === c2[2]) {
          if ((_ref1 = c1[2]) === "string" || _ref1 === "number" || _ref1 === "boolean" || _ref1 === "regexp" || _ref1 === "identifier" || _ref1 === "null") {
            return ret = c1[0] === c2[0];
          } else if (c1[2] === "uminus") {
            return ret = this.equal(c1[0], c2[0]);
          } else {
            return ret = this.equal(c1[0], c2[0]) && this.equal(c1[1], c2[1]);
          }
        }
      }
    },
    getIdentifiers: function(rule) {
      var propChain, ret, rule2;

      ret = [];
      rule2 = rule[2];
      if (rule2 === "identifier") {
        return [rule[0]];
      } else if (rule2 === "function") {
        ret.push(rule[0]);
        ret = ret.concat(this.getIdentifiers(rule[1]));
      } else if (rule2 !== "string" && rule2 !== "number" && rule2 !== "boolean" && rule2 !== "regexp" && rule2 !== "uminus") {
        if (rule2 === "prop") {
          ret = ret.concat(this.getIdentifiers(rule[0]));
          if (rule[1]) {
            propChain = rule[1];
            while (isArray(propChain)) {
              if (propChain[2] === "function") {
                ret = ret.concat(this.getIdentifiers(propChain[1]));
                break;
              } else {
                propChain = propChain[1];
              }
            }
          }
        } else {
          if (rule[0]) {
            ret = ret.concat(this.getIdentifiers(rule[0]));
          }
          if (rule[1]) {
            ret = ret.concat(this.getIdentifiers(rule[1]));
          }
        }
      }
      removeDups(ret);
      return ret;
    },
    toConstraints: function(rule, options) {
      var alias, ret, rule2, scope;

      ret = [];
      alias = options.alias;
      scope = options.scope || {};
      rule2 = rule[2];
      if (rule2 === "and") {
        ret = ret.concat(this.toConstraints(rule[0], options)).concat(this.toConstraints(rule[1], options));
      } else if (rule2 === "composite" || rule2 === "or" || rule2 === "lt" || rule2 === "gt" || rule2 === "lte" || rule2 === "gte" || rule2 === "like" || rule2 === "notLike" || rule2 === "eq" || rule2 === "neq" || rule2 === "in" || rule2 === "notIn" || rule2 === "function") {
        if (some(this.getIdentifiers(rule), function(i) {
          return i !== alias && !(i in definedFuncs) && !(i in scope);
        })) {
          ret.push(new atoms.ReferenceConstraint(rule, options));
        } else {
          ret.push(new atoms.EqualityConstraint(rule, options));
        }
      }
      return ret;
    },
    parse: function(rule) {
      return this[rule[2]](rule[0], rule[1]);
    },
    composite: function(lhs) {
      return this.parse(lhs);
    },
    and: function(lhs, rhs) {
      return [this.parse(lhs), "&&", this.parse(rhs)].join(" ");
    },
    or: function(lhs, rhs) {
      return [this.parse(lhs), "||", this.parse(rhs)].join(" ");
    },
    prop: function(name, prop) {
      var _ref1;

      if (_ref1 = prop[2], __indexOf.call("function", _ref1) >= 0) {
        return [this.parse(name), this.parse(prop)].join(".");
      } else {
        return [this.parse(name), "['", this.parse(prop), "']"].join("");
      }
    },
    unminus: function(lhs) {
      return -1 * this.parse(lhs);
    },
    plus: function(lhs, rhs) {
      return [this.parse(lhs), "+", this.parse(rhs)].join(" ");
    },
    minus: function(lhs, rhs) {
      return [this.parse(lhs), "-", this.parse(rhs)].join(" ");
    },
    mult: function(lhs, rhs) {
      return [this.parse(lhs), "*", this.parse(rhs)].join(" ");
    },
    div: function(lhs, rhs) {
      return [this.parse(lhs), "/", this.parse(rhs)].join(" ");
    },
    mod: function(lhs, rhs) {
      return [this.parse(lhs), "%", this.parse(rhs)].join(" ");
    },
    lt: function(lhs, rhs) {
      return [this.parse(lhs), "<", this.parse(rhs)].join(" ");
    },
    gt: function(lhs, rhs) {
      return [this.parse(lhs), ">", this.parse(rhs)].join(" ");
    },
    lte: function(lhs, rhs) {
      return [this.parse(lhs), "<=", this.parse(rhs)].join(" ");
    },
    gte: function(lhs, rhs) {
      return [this.parse(lhs), ">=", this.parse(rhs)].join(" ");
    },
    like: function(lhs, rhs) {
      return [this.parse(rhs), ".test(", this.parse(lhs), ")"].join("");
    },
    notLike: function(lhs, rhs) {
      return ["!", this.parse(rhs), ".test(", this.parse(rhs), ")"].join("");
    },
    eq: function(lhs, rhs) {
      return [this.parse(lhs), "===", this.parse(rhs)].join(" ");
    },
    neq: function(lhs, rhs) {
      return [this.parse(lhs), "!==", this.parse(rhs)].join(" ");
    },
    "in": function(lhs, rhs) {
      return ["(indexOf(", this.parse(rhs), ",", this.parse(lhs), ")) !== -1"].join("");
    },
    notIn: function(lhs, rhs) {
      return ["(indexOf(", this.parse(rhs), ",", this.parse(lhs), ")) === -1"].join("");
    },
    "arguments": function(lhs, rhs) {
      var ret;

      ret = [];
      if (lhs) {
        ret.push(this.parse(lhs));
      }
      if (rhs) {
        ret.push(this.parse(rhs));
      }
      return ret.join(",");
    },
    array: function(lhs) {
      var args;

      args = [];
      if (lhs) {
        args = this.parse(lhs);
        if (isArray(args)) {
          return args;
        } else {
          return ["[", args, "]"].join("");
        }
      }
      return ["[", args.join(","), "]"].join("");
    },
    "function": function(lhs, rhs) {
      return [lhs, "(", this.parse(rhs), ")"].join("");
    },
    string: function(lhs) {
      return "'" + lhs + "'";
    },
    number: function(lhs) {
      return lhs;
    },
    boolean: function(lhs) {
      return lhs;
    },
    regexp: function(lhs) {
      return lhs;
    },
    identifier: function(lhs) {
      return lhs;
    },
    "null": function() {
      return "null";
    }
  };

  toJs = exports.toJs = function(rule, scope) {
    var body, f, js, vars;

    js = lang.parse(rule);
    scope || (scope = {});
    vars = lang.getIdentifiers(rule);
    body = "var indexOf = definedFuncs.indexOf;" + map(vars, function(v) {
      var ret;

      ret = ["var ", v, " = "];
      if (definedFuncs.hasOwnProperty(v)) {
        ret.push("definedFuncs['", v, "']");
      } else if (scope.hasOwnProperty(v)) {
        ret.push("scope['", v, "']");
      } else {
        ret.push("'", v, "' in fact ? fact['", v, "'] : hash['", v, "']");
      }
      ret.push(";");
      return ret.join("");
    }).join("") + ("return !!(" + js + ");");
    f = new Function("fact, hash, definedFuncs, scope", body);
    return function(fact, hash) {
      return f(fact, hash, definedFuncs, scope);
    };
  };

  exports.getMatcher = function(rule, scope) {
    return toJs(rule, scope);
  };

  exports.toConstraints = function(constraint, options) {
    return lang.toConstraints(constraint, options);
  };

  exports.equal = function(c1, c2) {
    return lang.equal(c1, c2);
  };

  exports.getIdentifiers = function(constraint) {
    return lang.getIdentifiers(constraint);
  };

}).call(this);