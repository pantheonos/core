-- pantheon/libv.platform
-- Platform detection and specifics
-- By daelvn

-- Our current platform
-- Has to be a function since it can change on the run
PLATFORM = -> if term.getGraphicsMode
  switch term.getGraphicsMode
    when 0 then "VANILLA" -- vanilla cc
    when 1 then "LGFX"    -- limited graphics
    when 2 then "GFX"     -- graphics mode
  else "VANILLA"

-- TODO write functions that determine whether a pixel is a valid VANILLA, LGFX or GFX pixel.

--# setPixel #--
VANILLA_setPixel = (pixel) ->
  expect 1, pixel, {"VPixel"}
  term.setCursorPos pixel.x, pixel.y
  term.setBackgroundColor pixel.color -- TODO color may not be valid
  term.setTextColor (pixel.foreground or term.getTextColor!)
  term.write (pixel.char or " ")

LGFX_setPixel = (pixel) ->
  expect 1, pixel, {"VPixel"}
  term.setPixel pixel.x, pixel.y, pixel.color -- TODO color may not be valid

GFX_setPixel = (pixel) ->
  expect 1, pixel, {"VPixel"}
  term.setPixel pixel.x, pixel.y, pixel.color -- TODO color may not be valid

--# drawPixels #--
VANILLA_drawPixels = (sx, sy, pixels) ->
  expect 1, sx,     {"number"}
  expect 2, sy,     {"number"}
  expect 3, pixels, {"table"}
  pixell = [ [pixel.color for pixel in *line] for line in *pixels ] -- TODO transform pixel.color into a valid vanilla color

LGFX_drawPixels = (sx, sy, pixels) ->
  expect 1, sx,     {"number"}
  expect 2, sy,     {"number"}
  expect 3, pixels, {"table"}
  term.drawPixels sx, sy, pixels -- TODO check that this table of pixels has vanilla colors

GFX_drawPixels = (sx, sy, pixels) ->
  expect 1, sx,     {"number"}
  expect 2, sy,     {"number"}
  expect 3, pixels, {"table"}
  term.drawPixels sx, sy, pixels

{
  :PLATFORM
  :VANILLA_setPixel,   :LGFX_setPixel,   :GFX_setPixel
  :VANILLA_drawPixels, :LGFX_drawPixels, :GFX_drawPixels
}
