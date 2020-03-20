-- pantheon/libv.frame
-- Frame creation and management
-- By daelvn
import getIntersecting from require "libv.grid"

-- Create a new Frame
-- A frame has a fixed size no larger than the current screen.
Frame = (w, h) ->
  expect 1, w, {"number"}, "Frame"
  expect 2, h, {"number"}, "Frame"
  nw, nh = term.getSize!
  error "Frame is larger than the screen" if (w > nw) or (h > nh)
  return typeset {:w, :h}, "VFrame"

-- Captures a 3D region of a Grid with the dimensions of the Frame
capture = (frame) -> (grid) -> (x, y) ->
  expect 1, frame, {"VFrame"}, "capture"
  expect 2, grid,  {"VGrid"}, "capture"
  expect 3, x,     {"number"}, "capture"
  expect 4, y,     {"number"}, "capture"
  --
  gi = getIntersecting grid
  --
  region = {}
  nw, nh = term.getSize!
  w      = if (x+frame.w) > nw then nw-x else frame.w
  h      = if (y+frame.h) > nh then nh-y else frame.h
  for px=1, w
    rx         = px + x
    region[px] = {}
    for py=1, h
      ry             = py + y
      ied            = gi rx, ry
      kdump inspect ied
      region[px][py] = ied -- FIXME this isnt just returning a list of pixels
  --
  return typeset {:x, :y, :w, :h, :region, :frame}, "VRegion"

-- Internal util.
-- Gets the largest key in a table.
lkey = (t) ->
  largest = 0
  for n, v in npairs t
    if n > largest
      largest = n
  return largest

-- "Merges" all layers in a region
merge = (region) ->
  expect 1, region, {"VRegion"}, "merge"
  screen = {}
  reg    = region.region
  for x=1, #reg
    screen[x] = {}
    for y=1, #reg[x]
      screen[x][y] = reg[x][y][lkey reg[x][y]]
  return typeset {:region, :screen}, "VScreen"

{
  :Frame
  :capture, :merge
}