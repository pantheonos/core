-- pantheon/libv.pixel
-- Pixel creation and handling
-- By daelvn
import ColorIndex, toI   from require "libcolor"
import isValidColorIndex from require "libv.platform"

Pixel = (x, y, color, foreground=(ColorIndex toI term.getTextColor!), char=" ") ->
  expect 1, color,      {"ColorIndex"}
  expect 2, foreground, {"ColorIndex"}
  expect 3, char,       {"string"}
  error "Invalid color index #{color.value}"      unless isValidColorIndex color
  error "Invalid color index #{foreground.value}" unless isValidColorIndex foreground
  return typeset {
    :color, :foreground, :char
  }, "VPixel"

{ :Pixel }