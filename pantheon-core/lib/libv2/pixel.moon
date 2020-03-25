-- pantheon/libv2.pixel
-- Pixel creation and handling
-- By daelvn
import ColorIndex        from require "libcolor2"
import isValidColorIndex from require "libv2.platform"

-- Creates a new pixel
Pixel = (bg, fg, char=" ") ->
  expect 1, bg,   {"ColorIndex"},        "Pixel"
  expect 2, fg,   {"ColorIndex", "nil"}, "Pixel"
  expect 3, char, {"string"},            "Pixel"
  --
  error "Invalid color index #{bg.value}" unless isValidColorIndex bg
  if fg
    error "Invalid foreground color index #{bg.value}" unless isValidColorIndex fg
  --
  return typeset {
    :bg, :fg, :char
  }, "VPixel"

-- Compares two pixels
comparePixels = (pa, pb) ->
  if pa.bg.value != pb.bg.value
    return false
  if PLATFORM! == "VANILLA"
    if pa.fg.value != pb.fg.value
      return false
    if pa.char != pb.char
      return false
  --
  return true

{
  :Pixel, :comparePixels
}