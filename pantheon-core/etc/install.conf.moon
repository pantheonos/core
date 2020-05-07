{
  -- inspect:
  --   user:    "kikito"
  --   name:    "inspect.lua"
  --   target:  "/lib/"
  --   include: {"inspect.lua"}
  raisin:
    user:    "hugeblank"
    name:    "raisin"
    target:  "/lib/"
    include: {"raisin.lua"}
  libproc:
    user:         "pantheonos"
    name:         "libproc"
    target:       "/lib/"
    include:      {"libproc/init.lua"}
    dependencies: {"raisin"}
  procd:
    user:         "pantheonos"
    name:         "libproc"
    target:       "/bin/"
    include:      {"procd.lua"}
    dependencies: {"libproc"}
    postInstall: ->
      fs.move "/bin/procd.lua", "/bin/procd"
}