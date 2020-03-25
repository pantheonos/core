-- pantheon/libv.pixel
-- Pixel creation and handling
-- By daelvn
import ColorIndex, toI   from require "libcolor"
import isValidColorIndex from require "libv.platform"

Pixel = (color, foreground, char=" ") ->
  expect 1, color,      {"ColorIndex"},        "Pixel"
  expect 2, foreground, {"ColorIndex", "nil"}, "Pixel"
  expect 3, char,       {"string"},            "Pixel"
  error "Invalid color index #{color.value}" unless isValidColorIndex color
  if foreground
    error "Invalid foreground color index #{foreground.value}" unless isValidColorIndex foreground
  return typeset {
    :color, :foreground, :char
  }, "VPixel"

{ :Pixel }