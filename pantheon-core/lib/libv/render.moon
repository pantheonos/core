-- pantheon/libv.render
-- Rendering VScreens using abstractions
-- By daelvn
import setPixel, drawPixels from require "libv.platform"

-- The render position does not change here, but is instead determined
-- by the capture position. (See libv.frame.capture)
render = (scr) ->
  expect 1, scr, {"VScreen"}
  -- screen = scr.screen
  -- region = scr.region
  -- frame  = region.frame
  -- x, y   = region.x, region.y
  -- w, h   = region.w, region.h
  -- for sx=1, w
  --   for sy=1, h
  --     setPixel sx+x, sy+y, screen[sx][sy]
  drawPixels scr.region.x, scr.region.y, scr.screen

{ :render }