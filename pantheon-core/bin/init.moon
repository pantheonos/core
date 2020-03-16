-- pantheon/core - /bin/init
-- Entrypoint for Pantheon
-- By daelvn
term.clear!
term.setCursorPos 1, 1

-- Control flow:
--   /bin/init
--   -> Start process manager

--# collect BIOS globals #--
export bios = {
  :PA_BREAK, :PA_PRINT
  :expect
  :load, :loadfile, :dofile
  :bit32
  :sleep
}

--# general exported utils #--
-- fs.isFile
fs.isFile = (f) -> not fs.isDir f
-- math.root
math.root = (nth, n) -> return n^(1/nth)
-- table.getn
table.getn or= (t) ->
  len = 0
  for _, _ in pairs t do len += 1
  return len
-- npairs
-- ipairs, but does not stop if nil is found
export npairs = (t) ->
  keys = table.sort [k for k, v in pairs t when "number" == type k]
  i    = 0
  n    = #keys
  ->
    i += 1
    return keys[i], t[keys[i]] if i <= n

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

--# require & package #--
libpkg = dofile "/lib/libpkg/init.lua"
export package = libpkg.package
export require = libpkg.require

--# configuration #--
libconf = require "libconf"
export loadConfig  = libconf.loadConfig
export writeConfig = libconf.writeConfig

-- Wanted libs:
--   libperipheral
--   libev (event system) (includes parallel)
--   libv (for vws/pav)
--   libcolor
--   libhttp

-- Wanted programs:
--   pashell
--   vws/pav

--# start process manager #--
PA_PRINT "Loading process manager..."
import State, Thread from require "libproc"

-- Create main state
mainState = State "main", 1
call      = Thread mainState

term.clear!
PA_PRINT "Finished!"
PA_BREAK!