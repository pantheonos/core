-- pantheon/libconf
-- Configuration loading and saving
-- By daelvn
serpent = require "serpent"

-- Configuration files are stored in `/etc/` with `.conf` extensions
-- This module is written in a require manner, but with a different path and loaders.
libconf         = {}
libconf.loaded  = {}
libconf.path    = "?.conf.lua;" ..
                  "?/conf.lua;" ..
                  "/etc/?.conf.lua;" ..
                  "/etc/?/conf.lua;"
libconf.config  = "/\n;\n?\n!\n-"
libconf.preload = {}

-- normal conf loader and writer
loadConf = (name) ->
  name    = name\gsub "%.", "/"
  fullerr = ""
  for pattern in libconf.path\gmatch "[^;]+"
    path = pattern\gsub "%?", name
    if (fs.exists path) and (fs.isFile path)
      fn, err = loadfile path
      if fn then return fn, path else return nil, err
    else
      fullerr ..= "  no file '#{path}'\n"
  return nil, fullerr
writeConf = (name, dump) ->
  name    = name\gsub "%.", "/"
  fullerr = ""
  for pattern in libconf.path\gmatch "[^;]+"
    path = pattern\gsub "%?", name
    if (fs.exists path) and (fs.isFile path)
      with fs.open path, "w"
        return nil, "Could not open #{path}" unless .close
        \write dump
        \close!
      return true
    else
      fullerr ..= "  no file '#{path}'\n"
  return nil, fullerr

libconf.loaders = {
  ((name) -> if pkg = libconf.preload[name] then return pkg else return nil, "no field libconf.preload[#{name}]")
  loadConf
}
libconf.writers = {
  ((name, dump) -> if libconf.preload[name] then libconf.preload[name] = dump else return nil, "no field libconf.preload[#{name}]")
  writeConf
}

-- Loads a configuration file
sentinel   = {}
loadConfig = (name) ->
  expect 1, name, {"string"}, "loadConfig"
  if libconf.loaded[name] == sentinel
    error "Loop detected loading '#{name}'", 0
  if conf = libconf.loaded[name]
    return conf

  fullerr = "Configuration '#{name}' could not be loaded:\n"
  for searcher in *libconf.loaders
    loader, err = searcher name
    if loader
      libconf.loaded[name] = sentinel
      result               = loader err
      unless result == nil
        libconf.loaded[name] = result
        return result
      else
        libconf.loaded[name] = true
        return true
    else
      fullerr ..= err
  return fullerr, 2

-- Writes into a configuration file
writeConfig = (name) -> (tbl) ->
  expect 1, name, {"string"}, "writeConfig"
  expect 2, tbl, {"table"}, "writeConfig"
  --
  fullerr = "Configuration '#{name}' could not be written:\n"
  for writer in *libconf.writers
    result, err = writer name, serpent.pretty tbl
    if result
      return true
    else
      fullerr ..= err
  error fullerr, 2

{ :libconf, :loadConfig, :writeConfig }

