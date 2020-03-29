-- pantheon/libperiph
-- Peripheral management
-- By daelvn
native = peripheral

-- The objective of this library is to remove the concept of "sides", and having to know
-- the exact side you placed the peripheral at.

-- Constants
SIDES = { "front", "back", "left", "right", "top", "bottom" }

-- Capitalizes the first letter of a name
firstUpper = (str) -> str\gsub "^%l", string.upper

-- Checks whether a table contains an element
contains = (t, v) ->
  for vv in *t
    return true if v == v 
  return false

-- side: id, kind, methodl

-- Lists all found peripherals by side or ID
-- Practically equivalent to peripheral.getNames (native CC)
listAllNative = ->
  results = {}
  for side in *SIDES
    if native.isPresent side
      results[#results+1] = side
      if ("modem" == native.getType side) and not (native.call side, "isWireless")
        remoteResults = native.call side, "getNamesRemote"
        for result in *remoteResults
          results[#results+1] = result
  results

-- Checks whether a side is present
-- Practically equivalent to peripheral.isPresent (native CC)
isPresentNative = (side) ->
  expect 1, side, {"string"}, "isPresentNative"
  if (native.isPresent side) or (contains listAllNative!, side) 
    return true
  return false

-- Gets the type of a peripheral
-- Practically equivalent to peripheral.getType (native CC)
getTypeNative = (side) ->
  expect 1, side, {"string"}, "getTypeNative"
  if native.isPresent side
    return native.getType side
  for sd in *SIDES
    if ("modem" == native.getType side) and not (native.call side, "isWireless")
      if native.call sd, "isPresentRemote", side
        return native.call sd, "getTypeRemote", side

-- Calls a peripheral natively
callNative = (side) -> (method, ...) ->
  expect 1, side, {"string"}, "callNative"
  expect 2, method, {"string"}, "callNative"
  if native.isPresent side
    return native.call side, method, ...
  for sd in *SIDES
    if ("modem" == native.getType side) and not (native.call side, "isWireless")
      if native.call sd, "isPresentRemote", side
        return native.call sd, "callRemote", side, method, ...

-- Gets the methods of a peripheral
-- Practically equivalent to peripheral.getMethods (native CC)
getMethodsNative = (side) ->
  expect 1, side, {"string"}, "getMethodsNative"
  if native.isPresent side
    return native.getMethods side
  for sd in *SIDES
    if ("modem" == native.getType side) and not (native.call side, "isWireless")
      if native.call sd, "isPresentRemote", side
        return native.call sd, "getMethodsRemote", side

-- Wraps a Peripheral
Peripheral = (id, kind=(getTypeNative id), _methods=(getMethodsNative id)) ->
  expect 1, id, {"string"}, "Peripheral"
  expect 2, kind, {"string"}, "Peripheral"
  expect 3, _methods, {"table"}, "Peripheral"
  -- Build method list
  methods = {}
  for method in *_methods
    methods[method] = (P) ->
      expect 1, P, {"P#{firstUpper kind}"}, method
      return (...) -> (callNative id) method, ...
  -- Add special methods
  methods.meta = {
    exists:  -> isPresentNative id
    kind:    -> getTypeNative id
    methods: -> getMethodsNative id
    call:    -> callNative id
  }
  -- return object
  this = {:id, :kind, :methods}
  return typeset this, "P#{firstUpper kind}"

-- Creates a new peripheral with periphemu
-- Wraps a Peripheral
EmuPeripheral = (id, kind, ...) ->
  expect 1, id, {"string"}, "EmuPeripheral"
  expect 2, kind, {"string"}, "EmuPeripheral"
  -- create peripheral
  return false unless periphemu
  if ok = periphemu.create id, kind, ...
    -- wrap it
    return Peripheral id, kind, getMethodsNative id
  else
    -- could not create peripheral
    return false, "Could not create peripheral #{id}"

-- Removes a periphemu peripheral.
removeEmu = (ep) ->
  return false unless periphemu
  periphemu.remove ep.id

-- Returns a list of all found peripherals
-- Takes an optional function to filter the results.
-- These functions take the form:
--   (side/id, kind) -> boolean
-- Result will be added if boolean is true.
peripheral = (filter=(->true)) ->
  expect 1, filter, {"function"}, "peripheral"
  results = {}
  for id in *listAllNative!
    kind = getTypeNative id
    continue unless filter id, kind
    methods = getMethodsNative id
    results[#results+1] = Peripheral id, kind, methods

-- Creates a filter function to use with getPeripherals
--   myModem = getPeripherals find "modem"
find = (exp) -> (id, kind) -> exp == kind

-- Return
{
  :Peripheral, :EmuPeripheral, :peripheral, :find, :removeEmu
}