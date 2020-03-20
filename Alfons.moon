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
    for file in wildcard "pantheon-core/bin/**"
      continue if file\match "moon"
      fs.delete file
    for file in wildcard "pantheon-core/lib/**.lua"
      continue if file\match "raisin"
      continue if file\match "bdf"
      continue if file\match "json"
      continue if file\match "serpent"
      continue if file\match "inspect"
      fs.delete file

