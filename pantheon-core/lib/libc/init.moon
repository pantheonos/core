-- pantheon/libc
-- Core library for Pantheon
-- By daelvn

-- type function that respects __type and io.type
export typeof = (v) ->
  -- get metatable
  local meta
  if "table" == type v
    if type_mt = getmetatable v
      meta = type_mt.__type
  -- check how to obtain type
  -- __type
  if meta
    switch type meta
      when "function" then return meta v
      when "string"   then return meta
  -- io.type()
  elseif io.type v
    return "io"
  -- type()
  else
    return type v

-- sets __type for a table
export typeset = (v, ty) ->
  bios.expect 1, v, {"table"}
  if mt = getmetatable v
    mt.__type = ty
  else
    setmetatable v, __type: ty
  return v

-- expect, using typeof
export expect = (n, v, ts) ->
  bios.expect 1, n,  {"number"}
  bios.expect 3, ts, {"table"}
  for ty in *ts
    return true if ty == typeof v
  error "bad argument ##{n} (expected #{table.concat ts, ' or '}, got #{type v})", 2

-- fs.isFile
fs.isFile = (f) ->
  expect 1, f, {"string"}, "fs.isFile"
  not fs.isDir f

-- math.root
math.root = (nth, n) ->
  expect 1, nth, {"number"}, "math.root"
  expect 2, n,   {"number"}, "math.root"
  return n^(1/nth)

-- table.getn
table.getn or= (t) ->
  expect 1, t, {"table"}, {"table.getn"}
  len = 0
  for _, _ in pairs t do len += 1
  return len

-- table.undupe
table.undupe = (t) ->
  -- https://stackoverflow.com/questions/20066835/lua-remove-duplicate-elements
  hash, res = {}, {}
  for elem in *t
    unless hash[elem]
      table.insert res, elem
      hash[elem] = true
  return res

-- table.contains
table.contains = (t, e) ->
  for v in *t
    return true if v == e
  return false

-- os.timer (os.startTimer)
os.timer = os.startTimer

-- gets the platform
export PLATFORM = -> if term.getGraphicsMode
  switch term.getGraphicsMode!
    when 0 then "VANILLA" -- vanilla cc
    when 1 then "LGFX"    -- limited graphics
    when 2 then "GFX"     -- graphics mode
  else "VANILLA"

-- npairs
-- ipairs, but does not stop if nil is found
export npairs = (t) ->
  expect 1, t, {"table"}, "npairs"
  keys = [k for k, v in pairs t when "number" == type k]
  table.sort keys
  i    = 0
  n    = #keys
  ->
    i += 1
    return keys[i], t[keys[i]] if i <= n