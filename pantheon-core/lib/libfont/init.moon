-- pantheon/libfont
-- Font loading and writing
-- By daelvn
_fromBDF = require "libfont.bdf"
--_fromBDF = dofile "pantheon-core/lib/libfont/bdf.lua"
serpent = require "serpent"

-- Font format
--   /etc/fonts/example.font.lua
--   ---
--   {
--     name: fontname
--     width: 6
--     height: 9
--     characters:
--       [hex_codepoint]: {
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--         {true, true, true, true, true, true}
--       }
--   }

-- Loads a font from a path
loadFont = (path) ->
  expect 1, path, {"string"}
  return false, "#{path} does not exist" unless fs.exists path
  font = dofile path, {}
  return false, "#{path} is not a legal font" unless ("table" == type font) and font.name
  return typeset font, "Font"

-- Writes a font to a path
writeFont = (path, font) ->
  expect 1, path, {"string"}
  expect 2, font, {"Font"}
  with fs.open path, "w"
    return false, "Could not open #{path}" unless .close
    \write serpent.dump font
    \close!
  return true

-- Converts a font from bdf format into Pantheon format
bdfToPantheon = (name, bdf) ->
  expect 1, name, {"string"}
  expect 2, bdf,  {"table"}
  font = typeset {}, "Font"
  font.name       = name
  font.width      = bdf.bounds.width
  font.height     = bdf.bounds.height
  font.characters = {k, v.bitmap for k, v in pairs bdf.chars}
  return font

{
  :loadFont, :writeFont
  :bdfToPantheon
}