-- pantheon/libpkg
-- Implementation of the `package` Lua library.
-- By daelvn
package = {}

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

sentinel = {}
require  = (name) ->
  expect 1, name, {"string"}, "require"
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

-- Return
{ :package, :require }