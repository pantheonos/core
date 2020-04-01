-- pantheon/libv.render
-- Rendering VScreens using abstractions
-- By daelvn
import setPixel, drawPixels from require "libv.platform"
import comparePixels, Pixel from require "libv.pixel"
import getScreenSize        from require "libv.platform"
import ColorIndex           from require "libcolor"

-- base pixel
BASE_PIXEL = Pixel (ColorIndex 0), (ColorIndex 15), " "
-- caches the last render of an object for diffing
RENDER_CACHE = {}
-- constant render bias
RENDER_BIAS  = 25

-- Returns a list of different pixels between two screens
-- (x,y positions, not the actual pixels).
-- The screens must be the same size to be compared.
countDiffPixels = (scra, scrb) ->
  expect 1, scra, {"VScreen"}, "countDiffPixels"
  expect 2, scrb, {"VScreen"}, "countDiffPixels"
  -- Check that they are the same size
  if scra.region.w != scrb.region.w
    error "The two regions are not the same width"
  if scra.region.h != scrb.region.h
    error "The two regions are not the same height"
  -- Start counting pixels
  count = 0
  list  = {}
  for x=1, scra.region.w
    for y=1, scra.region.h
      unless comparePixels scra.screen[x][y], scrb.screen[x][y]
        count      += 1
        list[count] = {x, y}
  --
  return list, count

-- Calculates a diff between two screens (dirty rectangle)
-- Finds the dirty rectangle, returns its two corners.
-- The screens must be the same size to be compared.
diffScreens = (scra, scrb) ->
  expect 1, scra, {"VScreen"}, "diffScreens"
  expect 2, scrb, {"VScreen"}, "diffScreens"
  -- Check that they are the same size
  if scra.region.w != scrb.region.w
    error "The two regions are not the same width"
  if scra.region.h != scrb.region.h
    error "The two regions are not the same height"
  -- Find the first corner
  local x1, y1, b1
  for x=1, scra.region.w
    for y=1, scra.region.h
      unless comparePixels scra.screen[x][y], scrb.screen[x][y]
        x1, y1 = x, y
        b1     = true
        break
    break if b1
  -- Find the second corner, in reverse
  local x2, y2, b2
  for x=scra.region.w, 1, -1
    for y=scra.region.h, 1, -1
      unless comparePixels scra.screen[x][y], scrb.screen[x][y]
        x2, y2 = x, y
        b2     = true
        break
    break if b2
  -- Return corners and area
  drw, drh = x2-x1, y2-y1
  drarea   = drw*drh
  return x1, y1, x2, y2, drarea

-- Renders a screen based on pixel difference and dirty rectangle
render = (scr, bias=RENDER_BIAS) ->
  expect 1, scr, {"VScreen"}, "render"
  -- FIXME
  RENDER_CACHE[scr.id] = {}
  for x=1, scr.region.w
    RENDER_CACHE[scr.id][x] = {}
    for y=1, scr.region.h
      RENDER_CACHE[scr.id][x][y] = BASE_PIXEL
  -- Just render if screen is not cached
  unless RENDER_CACHE[scr.id]
    drawPixels scr.region.x, scr.region.y, scr.screen
    return true
  -- If we do have a cache, do comparison and find the fastest way
  -- to render.
  -- The "formula" used is:
  --   a-B < b: drawPixels
  --   a-B > b: setPixel list
  --     where
  --   a -> area of dirty rectangle
  --   b -> count of different pixels
  --   B -> a constant bias that accounts for "slowness"
  --        of the setPixel calls.
  -- Get dirty rectangle info
  x1, y1, x2, y2, drarea = diffScreens scr, RENDER_CACHE[scr.id]
  -- Get individual pixel count
  iplist, ipcount = countDiffPixels scr, RENDER_CACHE[scr.id]
  -- Formula
  if (drarea-bias) < ipcount
    -- drawPixels, but only the dirty rectangle
    -- clone the screen, but only the rows we need
    echo "using dirty rectangle method (#{drarea-bias} < #{ipcount})"
    newscr = {}
    for x=1, (x2-x1)
      newscr[x] = {}
      for y=1, (y2-y1)
        newscr[x][y] = scr.screen[x1+x-1][y1+y-1]
    drawPixels x1, y1, newscr
    return true
  else
    -- set individual pixels
    echo "setting individual pixels (#{drarea-bias} > #{ipcount})"
    for {x, y} in pairs iplist
      setPixel x, y, scr.screen[x][y]
  --
  RENDER_CACHE[scr.id] = scr

{
  :countDiffPixels, :diffScreens
  :render
}