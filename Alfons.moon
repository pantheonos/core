tasks:
  clone: =>
    clone "daelvn/pantheon-bios"
    clone "MCJack123/craftos2-rom", "pantheon-bios/reference/"
  compile_bios: =>
    moonc "pantheon-bios"
    sh "cosrun image import pantheon-bios/project.yml 0 --dir pantheon-bios/"
  compile: =>
    moonc "pantheon-core"
    -- remove extensions from files in bin
    for file in wildcard "pantheon-core/bin/*.lua"
      fs.move file, basename file
  run: => sh "cosrun run core --rom"

