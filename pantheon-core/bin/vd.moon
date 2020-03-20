-- pantheon/vd
-- V Render Host Daemon
-- By daelvn
config = loadConfig "vd"
libv   = {
  grid:   require "libv.grid"
  frame:  require "libv.frame"
  buffer: require "libv.buffer"
  render: require "libv.render"
}
echo   = kdprint "vd"

-- This file is meant to be the Render Host for V apps. Requests are made to this
-- host which are then, in fact, drawn.
echo "starting server"

-- Create main grid
import Grid from libv.grid
GRID = switch config.gridSize
  when "screen" then Grid term.getSize!
  else               Grid config.gridSize[1], config.gridSize[2]

-- Create default frame
import Frame from libv.frame
FRAME = switch config.frameSize
  when "screen" then Frame term.getSize!
  else               Frame config.frameSize[1], config.frameSize[2]

-- Internal function to add new buffers
import Reference from libv.grid
newBuffer = Reference GRID

-- Internal function to create a capture
import capture from libv.frame
newCapture = ((capture FRAME) GRID)

-- TODO I need to find a way of using the Term API with V as the backend.
-- Only methods not available are redraw methods, since rendering is not done by the individual
-- windows but by the server instead.
import PLATFORM from require "libv.platform"
echo "running on graphics platform #{PLATFORM!}"

-- Export the vrh table
export vrh = { :GRID, :FRAME }

-- Creates a new "window"
import Buffer from libv.buffer
vrh.Window = (def) ->
  expect 1, def.x, {"number"}, "vrh.Window"
  expect 2, def.y, {"number"}, "vrh.Window"
  expect 3, def.d, {"number"}, "vrh.Window"
  x, y, d             = def.x, def.y, def.d
  def.x, def.y, def.d = nil, nil, nil
  --
  window = Buffer def
  newBuffer x, y, d, window
  return window

-- Renders the whole screen
-- Does no diffing, so no optimization happens here
vrh.render = ->
  screen = libv.frame.merge newCapture 1, 1
  libv.render.render screen

-- i dont think we need an actual loop for now
PA_BREAK!