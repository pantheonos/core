-- pantheon/vd
-- V Render Host Daemon
-- By daelvn
config = loadConfig "vd"
libv   = {
  grid:  require "libv.grid"
  frame: require "libv.frame"
}

-- This file is meant to be the Render Host for V apps. Requests are made to this
-- host which are then, in fact, drawn.

-- Create main grid
import Grid from libv.grid
GRID = switch config.gridSize
  when "screen"
    Grid term.getSize!
  when "default"
    Grid 51, 19
  else
    Grid config.gridSize[1], config.gridSize[2]

-- Create default frame
import Frame from libv.frame
FRAME = switch config.frameSize
  when "screen"
    Frame term.getSize!
  when "default"
    Frame 51, 19
  else
    Frame config.frameSize[1], config.frameSize[2]

-- Internal unction to add new buffers
import Reference from libv.grid
newBuffer = Reference GRID

-- Internal function to create a capture
import capture from libv.frame
newCapture = ((capture FRAME) GRID)

-- TODO I need to find a way of using the Term API with V as the backend.
-- Only methods not available are redraw methods, since rendering is not done by the individual
-- windows but by the server instead.
