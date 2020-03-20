-- pantheon/libv.platform
-- Platform detection and specifics
-- By daelvn

-- Our current platform
-- Has to be a function since it can change on the run
PLATFORM = -> if term.getGraphicsMode
  switch term.getGraphicsMode!
    when 0 then "VANILLA" -- vanilla cc
    when 1 then "LGFX"    -- limited graphics
    when 2 then "GFX"     -- graphics mode
  else "VANILLA"

--# isValidColorIndex #--
VANILLA_isValidColorIndex = (idx) ->
  expect 1, idx, {"ColorIndex"}, "VANILLA_isValidColorIndex"
  kprint "ivci/vanilla-lgfx: #{idx.value}:#{idx.gfx} (#{PLATFORM!})"
  return not idx.gfx

LGFX_isValidColorIndex = VANILLA_isValidColorIndex

GFX_isValidColorIndex = (idx) ->
  expect 1, idx, {"ColorIndex"}, "GFX_isValidColorIndex"
  kprint "ivci/gfx: #{idx.value}:#{idx.gfx} (#{PLATFORM!})"
  return idx.gfx

isValidColorIndex = (idx) ->
  switch PLATFORM!
    when "VANILLA" then VANILLA_isValidColorIndex idx
    when "LGFX"    then LGFX_isValidColorIndex    idx
    when "GFX"     then GFX_isValidColorIndex     idx

--# setPixel #--
VANILLA_setPixel = (x, y, pixel) ->
  expect 1, x, {"number"}, "VANILLA_setPixel"
  expect 2, y, {"number"}, "VANILLA_setPixel"
  expect 3, pixel, {"VPixel"}, "VANILLA_setPixel"
  error "Invalid color index #{pixel.color.value}" unless VANILLA_isValidColorIndex pixel.color
  term.setCursorPos x, y
  term.setBackgroundColor pixel.color.value
  term.setTextColor (pixel.foreground or term.getTextColor!)
  term.write (pixel.char or " ")

LGFX_setPixel = (x, y, pixel) ->
  expect 1, x, {"number"}, "LGFX_setPixel"
  expect 2, y, {"number"}, "LGFX_setPixel"
  expect 3, pixel, {"VPixel"}, "LGFX_setPixel"
  error "Invalid color index #{pixel.color.value}" unless LGFX_isValidColorIndex pixel.color
  term.setPixel x, y, pixel.color.value

GFX_setPixel = (x, y, pixel) ->
  expect 1, x, {"number"}, "GFX_setPixel"
  expect 2, y, {"number"}, "GFX_setPixel"
  expect 3, pixel, {"VPixel"}, "GFX_setPixel"
  kprint "GFX_setPixel was called"
  error "Invalid color index #{pixel.color.value}" unless GFX_isValidColorIndex pixel.color
  term.setPixel x, y, pixel.color.value

-- abstraction
setPixel = (x, y, pixel) -> switch PLATFORM!
  when "VANILLA" then VANILLA_setPixel x, y, pixel
  when "LGFX"    then LGFX_setPixel    x, y, pixel
  when "GFX"     then GFX_setPixel     x, y, pixel

--# drawPixels #--
VANILLA_drawPixels = (sx, sy, pixels) ->
  expect 1, sx, {"number"}, "VANILLA_drawPixels"
  expect 2, sy, {"number"}, "VANILLA_drawPixels"
  expect 3, pixels, {"table"}, "VANILLA_drawPixels"
  for y, line in ipairs pixels
    for x, pixel in ipairs line
      VANILLA_setPixel (x+sx), (y+sy), pixel

LGFX_drawPixels = (sx, sy, pixels) ->
  expect 1, sx, {"number"}, "LGFX_drawPixels"
  expect 2, sy, {"number"}, "LGFX_drawPixels"
  expect 3, pixels, {"table"}, "LGFX_drawPixels"
  final = {}
  for y, line in ipairs pixels
    final[y] = {}
    for x, pixel in ipairs line
      error "Invalid color index #{pixel.color.value}" unless LGFX_isValidColorIndex pixel.color
      final[y][x] = pixel.color.value
  term.drawPixels sx, sy, final

GFX_drawPixels = (sx, sy, pixels) ->
  expect 1, sx,     {"number"}, "GFX_drawPixels"
  expect 2, sy,     {"number"}, "GFX_drawPixels"
  expect 3, pixels, {"table"}, "GFX_drawPixels"
  final = {}
  for y, line in ipairs pixels
    final[y] = {}
    for x, pixel in ipairs line
      kprint "-> #{x},#{y}: #{inspect pixel}"
      error "Invalid color index #{pixel.color.value}" unless GFX_isValidColorIndex pixel.color
      final[y][x] = pixel.color.value
  term.drawPixels sx, sy, final

-- abstraction
drawPixels = (sx, sy, pixels) -> switch PLATFORM!
  when "VANILLA" then VANILLA_drawPixels sx, sy, pixels
  when "LGFX"    then LGFX_drawPixels    sx, sy, pixels
  when "GFX"     then GFX_drawPixels     sx, sy, pixels

{
  :PLATFORM
  :VANILLA_isValidColorIndex, :LGFX_isValidColorIndex, :GFX_isValidColorIndex, :isValidColorIndex
  :VANILLA_setPixel,          :LGFX_setPixel,          :GFX_setPixel,          :setPixel
  :VANILLA_drawPixels,        :LGFX_drawPixels,        :GFX_drawPixels,        :drawPixels
}
