-- pantheon/core - /bin/init
-- Entrypoint for Pantheon
-- By daelvn
term.clear!
term.setCursorPos 1, 1

export K_VERSION = "0.1"

-- Control flow:
--   /bin/init
--   -> Start process manager

--# collect BIOS globals #--
export bios = {
  :PA_BREAK, :PA_PRINT, :PA_VERSION
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
  keys = [k for k, v in pairs t when "number" == type k]
  table.sort keys
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

--# inspecting #--
export inspect = require "inspect"

-- load pantheon configuration
config = loadConfig "kernel"

--# peripherals #--
libperiph = require "libperiph"
export Peripheral  = libperiph.Peripheral 
export peripherals = libperiph.peripherals
export findPeriph  = libperiph.find

-- attach debugger
if config.debug
  export dbg     = libperiph.EmuPeripheral "debug0", "debugger"
  export kprint  = dbg.methods.print dbg
  export kdprint = (tag) -> (text) -> (dbg.methods.print dbg) "#{tag}: #{text}"
  export kbreak  = dbg.methods.stop dbg
  export kdump   = (text) ->
    with fs.open "/kdump.txt", "w"
      .write text
      .close!
  -- expect, using typeof and debug
  export expect = (n, v, ts, fr="") ->
    bios.expect 1, n,  {"number"}
    bios.expect 3, ts, {"table"}
    for ty in *ts
      return true if ty == typeof v
    kprint "#{fr}: bad argument ##{n} (expected #{table.concat ts, ' or '}, got #{type v})", 2
    kbreak!
  -- print message
  kprint "pakernel #{K_VERSION} running on pabios #{PA_VERSION}"
else
  export kprint  = ->
  export kdprint = -> ->

-- set graphics mode
switch config.graphics
  when "VANILLA" then term.setGraphicsMode 0
  when "LGFX"    then term.setGraphicsMode 1
  when "GFX"     then term.setGraphicsMode 2
kprint "gfx mode: #{config.graphics or 'VANILLA'}"

-- Wanted libs:
--   libev (event system) (includes parallel)
--   libv (for vws/pav)
--   libhttp

-- Wanted programs:
--   pashell
--   vws/pav

--# start process manager #--
import State, Thread, runState from require "libproc"

-- Create main state
kprint "- creating libproc/main state"
mainState = State "main", 1
call      = Thread mainState

--# register daemons #--
kprint "- registering daemons"
call loadfile "/bin/pd" -- peripheral daemon
--call loadfile "/bin/vd" -- VRH daemon
call loadfile "/bin/vd"

--# register example program #--
kprint "- registering example program"
call loadfile "/bin/example/fontrender-vd"

--# run main state #--
kprint "- running main state"
runState mainState

--term.clear!
kprint "kernel exectution completed"
PA_BREAK!