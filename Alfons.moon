tasks:
  -- clone repositories
  clone: =>
    clone "daelvn/pantheon-bios"
    clone "MCJack123/craftos2-rom", "pantheon-bios/reference/"
  -- compile bios
  compile_bios: =>
    for file in wildcard "pantheon-bios/**.moon"
      continue if file\match "Alfons"
      moonc file
    sh "cosrun image import pantheon-bios/project.yml 0 --dir pantheon-bios/"
  -- compile all other files
  compile: =>
    moonc "pantheon-core"
    -- remove extensions from files in bin
    for file in wildcard "pantheon-core/bin/**.lua"
      fs.move file, basename file
  -- run project
  run: => sh "cosrun run core --rom"
  -- clean lua files
  clean: =>
    -- delete in /bin
    for file in wildcard "pantheon-core/bin/**"
      continue if file\match "moon"
      continue if file\match "gitget"
      fs.delete file
    -- delete in /tmp
    for file in wildcard "pantheon-core/tmp/*"
      fs.delete file
    -- delete in /lib/**
    for file in wildcard "pantheon-core/lib/**.lua"
      --continue if file\match "raisin"
      continue if file\match "json.lua"
      continue if file\match "serpent.lua"
      continue if file\match "inspect.lua"
      continue if file\match "nap.lua"
      fs.delete file
  clean_libs: =>
    for node in wildcard "pantheon-core/lib/*"
      continue if node\match "json.lua"
      continue if node\match "serpent.lua"
      continue if node\match "inspect.lua"
      continue if node\match "README.md"
      continue if node\match "libc"
      continue if node\match "libconf"
      continue if node\match "libpkg"
      continue if node\match "libperiph"
      continue if node\match "libhttp"
      continue if node\match "libgit"
      fs.delete node