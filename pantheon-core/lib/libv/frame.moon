-- pantheon/libv.frame
-- Frame creation and management
-- By daelvn
import getIntersecting from require "libv.grid"
import Pixel           from require "libv.pixel"
import getScreenSize   from require "libv.platform"
import ColorIndex      from require "libcolor"

BASE_PIXEL = Pixel (ColorIndex 0), (ColorIndex 15), " "
FRAME_ID   = 0
-- Create a new Frame
-- A frame has a fixed size no larger than the current screen.
-- Each frame also has an ID number for render caches.
Frame = (w, h) ->
  expect 1, w, {"number"}, "Frame"
  expect 2, h, {"number"}, "Frame"
  nw, nh = getScreenSize!
  error "Frame is larger than the screen" if (w > nw) or (h > nh)
  --
  id        = FRAME_ID
  FRAME_ID += 1
  return typeset {:w, :h, :id}, "VFrame"

-- Captures a 3D region of a Grid with the dimensions of the Frame
capture = (frame) -> (grid) -> (x, y) ->
  expect 1, frame, {"VFrame"}, "capture"
  expect 2, grid,  {"VGrid"},  "capture"
  expect 3, x,     {"number"}, "capture"
  expect 4, y,     {"number"}, "capture"
  --
  gi = getIntersecting grid
  --
  region = {}
  nw, nh = getScreenSize!
  -- Set the total region width and height
  -- If it overflows from the screen, just stop at the end.
  -- Otherwise, just do normal length.
  w = if (x+frame.w) > nw then nw-x else frame.w
  h = if (y+frame.h) > nh then nh-y else frame.h
  -- Now iterate the lengths
  for px=1, w
    -- x  -> real starting point
    -- px -> relative position
    -- rx -> real position (px+x)
    rx        = px+x
    region[px] = {}
    for py=1, h
      -- y  -> real starting point
      -- py -> relative position
      -- ry -> real position (py+y)
      ry = py + y
      -- get intersected points
      -- intersect lists have the format:
      --   {
      --     [d]: {
      --       gx     -> absolute x
      --       gy     -> absolute y
      --       bx     -> relative x
      --       by     -> relative y
      --       buffer -> related buffer
      --     }
      --   }
      ied            = gi rx, ry
      if #ied == 0
        region[px][py] = {{}}
      else
        region[px][py] = ied
      --
      return typeset {:x, :y, :w, :h, :region, :frame}, "VRegion"

-- Internal util.
-- Gets the largest key in a table.
lkey = (t) ->
  return nil unless "table" == typeof t
  largest = 0
  for n, v in npairs t
    if n > largest
      largest = n
  return largest

-- Takes a table in format {gx, gy, bx, by, buffer} and returns
-- the pixel it points to.
pixelFor = (int) ->
  if int.buffer[int.bx] and int.buffer[int.bx][int.by]
    return int.buffer[int.bx][int.by]
  else
    return nil

-- Merges all layers in a region
merge = (region) ->
  expect 1, region, {"VRegion"}, "merge"
  screen = {id: region.frame.id}
  reg    = region.region
  --
  for x=1, region.w
    screen[x] = {}
    for y=1, region.h
      -- The screen will have the format
      --   {
      --     [x]:
      --       [y]:
      --         Pixel
      --   }
      if reg[x] and reg[x][y]
        screen[x][y] = pixelFor reg[x][y][(lkey reg[x][y]) or 1]
      else
        screen[x][y] = BASE_PIXEL
  --
  return typeset { :region, :screen }, "VScreen"

{
  :BASE_PIXEL
  :Frame
  :capture, :merge
}