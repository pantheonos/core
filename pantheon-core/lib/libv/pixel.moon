-- pantheon/libv.pixel
-- Pixel creation and handling
-- By daelvn

Pixel = (x, y, color, foreground=term.getTextColor!, char=" ") ->
  -- TODO check that color is valid for the platform being used
  -- Do that with an underlying color check that is platform-specific
  -- All that isn't libv.platform should be heavily abstracted
  return typeset {
    :x, :y, :color, :foreground, :char
  }, "VPixel"