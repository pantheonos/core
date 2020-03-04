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
export package = {}

package.loaded = {
  :_G
  :bit32
  :coroutine
  :math
  :package
  :string
  :table
}
package.path = "?;" ..
               "?.lua;" ..
               "?/init.lua;" ..
               "/lib/?;" ..
               "/lib/?.lua;" ..
               "/lib/?/init.lua;"
package.config  = "/\n;\n?\n!\n-"
package.preload = {}

-- normal module loader
loadLib = (name) ->
  name    = name\gsub "%.", "/"
  fullerr = ""
  for pattern in package.path\gmatch "[^;]+"
    path = pattern\gsub "%?", name
    if (fs.exists path) and (fs.isFile path)
      fn, err = loadfile path
      if fn then return fn, path else return nil, err
    else
      fullerr ..= "  no file '#{path}'\n"
  return nil, fullerr


package.loaders = {
  ((name) -> if pkg = package.preload[name] then return pkg else return nil, "no field package.preload[#{name}]")
  loadLib
}

sentinel       = {}
export require = (name) ->
  expect 1, name, {"string"}
  if package.loaded[name] == sentinel
    error "Loop detected requiring '#{name}'", 0
  if pkg = package.loaded[name]
    return pkg

  fullerr = "Package '#{name}' could not be loaded:\n"
  for searcher in *package.loaders
    loader, err = searcher name
    if loader
      package.loaded[name] = sentinel
      result               = loader err
      unless result == nil
        package.loaded[name] = result
        return result
      else
        package.loaded[name] = true
        return true
    else
      fullerr ..= err
  error fullerr, 2

-- Wanted libs:
--   libfont
--   libperipheral
--   libkbd
--   libev (event system) (includes parallel)
--   libv (for vws/pav)
--   libcolor
--   libconf (settings)
--   libhttp

-- Wanted programs:
--   pashell
--   vws/pav

--# start process manager #--
PA_PRINT "Loading process manager..."

term.clear!
PA_PRINT "Loaded!"
PA_BREAK!