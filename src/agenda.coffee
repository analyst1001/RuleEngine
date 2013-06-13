###

  Describes a FactHash object and an Agenda object for handling agendas

  sortAgenda(a, b) --> 1 or -1
    a --> most probably a tree node
    b --> most probably a tree node
  returns 1 or -1 to indicate the ordering of nodes

  FactHash object
    memory --> a list of facts
    memoryValues --> a list of lists containing values related to fact a corresponding index

    clear() --> empties memory and memoryValues

    get(k) --> List
      k --> fact related to which values are to be get
    returns a list of values related to fact

    __compact() --> removes the facts from memory which do not have any values

    remove(v) --> Nothing
      v --> Value to remove
    removes the value from all the facts it is present in

    insert(insert) --> Nothing
      insert --> values to be inserted
    insert the value in all facts the value is to be inserted in

    Agenda Object
      agendaGroups --> dictionary for storing AVL tree corresponding to an agenda
      agendaGroupStack --> a list for keeping track of currently focussed agenda
      rules --> a dictionary ???
      flow --> ???
      addAgendaGroup(groupName) --> Nothing
        groupName --> Name of the agenda group to add
      adds the agenda group to the agendaGroups dictionary

      getAgendaGroup(groupName) --> AVLTree object
        groupName --> Name of the agenda group whose AVL tree is to be obtained
      returns the AVL tree corresponding to a group name

      setFocus(agendaGroup) --> Agenda object
        agendaGroup --> the agenda group to be set on focus
      returns a modified Agenda object with agendaGroup parameter focused

      getFocused() -> returns the agendaGroup which is currently focused

      getFocusedAgenda() --> returns the AVL tree corresponding to the currently focused agenda group

      register(node) --> Nothing
        node --> the node to be registered in Agenda object
      updates the Agenda object to get the node registered

      isEmpty() --> Boolean
      returns True if there are no agenda groups with anything in their corresponding AVL trees

      fireNext() --> Boolean
      fires the next activation rule

      pop() --> ???
      removes the last node from the currently focused agenda

      removeByFact(node, fact) --> ???

      retract(node, cb) --> Nothing
      removes data from factTable, AVLtree corresponding to the agenda groupn and tree corresponding to the rule corresponding to the node depending on the callback function

      insert(node, insert) --> Nothing
        node --> a tree node
        insert --> value to be inserted
      inserts the insert parameter in the tree, agendaGroup and factTable corresponding to the rule corresponding to the node

      dispose() --> clears all the data structures in the Agenda object
###

"use strict"

extd = require('./extended')
When = extd.when
indexOf = extd.indexOf
declare = extd.declare
AVLTree = extd.AVLTree
EventEmitter = require("events").EventEmitter

sortAgenda = (a, b) ->
  if a is b then return 0
  p1 = a.rule.priority
  p2 = b.rule.priority
  if (p1 isnt p2)
    ret = p1 - p2
  else if a.counter isnt b.counter 
    ret = a.counter - b.counter 
  if not ret 
    i = 0
    aMatchRecency = a.match.recency 
    bMatchRecency = b.match.recency
    aLength = aMatchRecency.length - 1
    bLength = bMatchRecency.length - 1
    while (aMatchRecency[i] is bMatchRecency[i] and i < aLength and i < bLength) 
      i++
    ret = aMatchRecency[i] - bMatchRecency[i]
    if not ret then ret = aLength - bLength
  if not ret then ret = a.recency - b.recency
  return (if ret > 0 then 1 else -1)

FactHash = declare(
  instance :
    constructor : ->
      @memory = []
      @memoryValues = []

    clear : ->
      @memory.length = @memoryValues.length = 0

    get : (k) -> return @memoryValues[indexOf(@memory, k)]

    __compact : () ->
      oldM = @memory.slice(0)
      oldMv = @memoryValues.slice(0)
      @memory = []
      @memoryValues = []
      @memoryValues[@memory.push(oldM[i]) - 1] = oldMemoryValue for oldMemoryValue, i in oldMv when oldMemoryValue.length isnt 0

    remove : (v) ->
      facts = v.match.facts
      for fact in facts
        i = indexOf(@memory, fact)
        arr = @memoryValues[i]
        index = indexOf(arr, v)
        arr.splice(index,1)
      @__compact()

    insert : (insert) ->
      facts = insert.match.facts
      for fact in facts
        i = indexOf(@memory, fact)
        arr = @memoryValues[i]
        arr = @memoryValues[@memory.push(fact) - 1] = [] if not arr 
        arr.push(insert)
)

REVERSE_ORDER = AVLTree.REVERSE_ORDER
DEFAULT_AGENDA_GROUP = "main"

module.exports = declare(EventEmitter, 
  instance : 
    constructor : (flow) ->
      @agendaGroups = {}
      @agendaGroupStack = [DEFAULT_AGENDA_GROUP]
      @rules = {}
      @flow = flow
      @setFocus(DEFAULT_AGENDA_GROUP).addAgendaGroup(DEFAULT_AGENDA_GROUP)

    addAgendaGroup : (groupName) ->
      @agendaGroups[groupName] = new AVLTree({compare : sortAgenda}) if not extd.has(@agendaGroups, groupName)

    getAgendaGroup : (groupName) -> return @agendaGroups[groupName or DEFAULT_AGENDA_GROUP]

    setFocus : (agendaGroup) ->
      if agendaGroup isnt @getFocused()
        @agendaGroupStack.push(agendaGroup)
        @emit("focused", agendaGroup)
      return this

    getFocused : -> return @agendaGroupStack[@agendaGroupStack.length - 1]

    getFocusedAgenda : -> return @agendaGroups[@getFocused]

    register : (node) ->
      agendaGroup = node.rule.agendaGroup
      @rules[node.name] = {tree : new AVLTree({compare : sortAgenda}), factTable : new FactHash()}
      @addAgendaGroup(agendaGroup) if agendaGroup  

    isEmpty : ->
      changed = false
      while @getFocusedAgenda().isEmpty() and @getFocused isnt DEFAULT_AGENDA_GROUP
        @agendaGroupStack.pop()
        changed = true
      emit("focused", @getFocused) if changed
      @getFocusedAgenda.isEmpty()

    fireNext : ->
      while @getFocusedAgenda().isEmpty() and @getFocused isnt DEFAULT_AGENDA_GROUP
        @agendaGroupStack.pop()
      if not @getFocusedAgenda().isEmpty()
        activation = @pop()
        @emit("fire", activation.rule.name, activation.match.FactHash)
        return When(activation.rule.fire(@flow, activation.match)).then(-> return true)
      return extd.resolve(false)

    pop : ->
      tree = @getFocusedAgenda
      root = tree.__root
      while (root.right)
        root = root.right
      v = root.data 
      tree.remove(v)
      rule = @rules[v.name]
      rule.tree.remove(v)
      rule.factTable.remove(v)
      return v 

    removeByFact : (node, fact) ->
      rule = @rules[node.name]
      tree = rule.tree
      factTable = rule.factTable
      ma = @getAgendaGroup(node.rule.agendaGroup)
      remove = factTable.get(fact) or []
      for r in remove
        factTable.remove(r)
        tree.remove(r)
        ma.remove(r)
      remove.length = 0

    retract : (node, cb) ->
      rule = @rules[node.name]
      tree = rule.tree
      factTable = rule.factTable
      ma = @getAgendaGroup(node.rule.agendaGroup)
      tree.traverse(tree.__root, REVERSE_ORDER, (v) ->
        if cb(v)
          ma.remove(v)
          tree.remove(v)
      )
    
    insert : (node, insert) ->
      rule = @rules[node.name]
      nodeRule = node.rule
      agendaGroup = nodeRule.agendaGroup
      rule.tree.insert(insert)
      @getAgendaGroup(agendaGroup).insert(insert)
      @setFocus(agendaGroup) if agendaGroup and nodeRule.autoFocus
      rule.factTable.insert(insert)

    dispose : ->
      @agendaGroups[i].clear for i of @agendaGroups
      rules = @rules
      for i in rules
        rules[i].tree.clear()
        rules[i].factTable.clear()
      @rules = {}
  )