-- pantheon/libfont
-- Font loading and writing
-- By daelvn
_fromBDF = require "libfont.bdf"
serpent = require "serpent"

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

{
  :loadFont, :writeFont
}