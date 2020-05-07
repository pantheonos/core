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

--# load libc #--
libc = dofile "/lib/libc/init.lua"

--# require & package #--
libpkg = dofile "/lib/libpkg/init.lua"
export package = libpkg.package
export require = libpkg.require

--# configuration #--
libconf = require "libconf"
export loadConfig  = libconf.loadConfig
export writeConfig = libconf.writeConfig

--# installation #--

--# kikito libs #--
export inspect = require "inspect"
--export memoize = require "memoize"

-- load pantheon configuration
config = loadConfig "kernel"
-- set some defaults
config.debug or= false
config.http  or= true

--# peripherals #--
libperiph = require "libperiph"
export Peripheral  = libperiph.Peripheral 
export peripherals = libperiph.peripherals
export findPeriph  = libperiph.find

-- attach debugger
if config.debug
  -- create debugger peripheral
  export dbg = libperiph.EmuPeripheral "debug0", "debugger"
  error "Could not attach debugger. Halting." unless dbg
  -- export debugging symbols
  defineAll = require "libc.debug"
  defineAll dbg
  -- print message
  kprint "pakernel #{K_VERSION} running on pabios #{PA_VERSION}"
else
  export kprint  = ->
  export kdprint = -> ->

--# http #--
libhttp = require "libhttp"

-- set graphics mode
switch config.graphics
  when "VANILLA" then term.setGraphicsMode 0
  when "LGFX"    then term.setGraphicsMode 1
  when "GFX"     then term.setGraphicsMode 2
kprint "gfx mode: #{config.graphics or 'VANILLA'}"

--# installation #--
import install, uninstall from require "libc.install"
install_list = {
  "procd"
  "vd"
}
for pkg in *install_list
  ok, err = install pkg
  unless ok
    error "Could not install #{pkg}: #{err}"

-- Wanted libs:
--   libev (event system) (includes parallel)
--   libv (for vws/pav)
--   libhttp

-- Wanted programs:
--   pashell
--   vws/pav

--# start proc management #--
import runProcd from dofile "/bin/procd"

--# register daemons #--
kprint "- registering daemons"
callFile "/bin/pd" -- peripheral daemon
--callFile "/bin/vd" -- rendering daemon

--# register example program #--
kprint "- registering example program"
--callFile "/bin/example/fontrender"

--# run main state #--
kprint "- running procd"
runProcd!

-- delete /tmp/ contents
--kprint "- deleting contents of /tmp/"
--for file in *fs.list "/tmp/"
--  fs.delete "/tmp/#{file}"

--term.clear!
kprint "kernel exectution completed"
PA_BREAK!
