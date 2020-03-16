-- pantheon/libv.buffer
-- Buffer creation and handling
-- By daelvn

-- Create a new Buffer
-- A buffer has a width and height, and is placed on an absolute Grid (libv.grid)
Buffer = =>
  -- set defaults
  @visible   or= true
  @movable   or= true
  @resizable or= true
  @writable  or= true
  --
  expect 0, @,          {"table"}
  expect 1, @w,         {"number"}
  expect 2, @h,         {"number"}
  expect 4, @visible,   {"boolean"}
  expect 5, @movable,   {"boolean"}
  expect 6, @resizable, {"boolean"}
  expect 7, @writable,  {"boolean"}
  --
  error "Width must be above 0" if @w < 1
  error "Height must be above 0" if @h < 1
  --
  @buffer = {}
  this = typeset @, "VBuffer"

-- Resize a buffer
resize = => (w, h) ->
  expect 1, @, {"VBuffer"}
  expect 2, w, {"number"}
  expect 3, h, {"number"}
  error "Width must be above 0" if w < 1
  error "Height must be above 0" if h < 1
  return false unless @resizable
  @w, @h = w, h
  return true

-- Sets a pixel in the buffer
setPixel = => (x, y, pixel) ->
  expect 1, @,     {"VBuffer"}
  expect 2, x,     {"number"}
  expect 3, y,     {"number"}
  expect 4, pixel, {"VPixel"}
  return false unless @writable
  return false if (x > @w) or (y > @h)
  @buffer[x]    = {} unless @buffer[x]
  @buffer[x][y] = pixel
  return true

-- Unsets a pixel in the buffer
unsetPixel = => (x, y) ->
  expect 1, @, {"VBuffer"}
  expect 2, x, {"number"}
  expect 3, y, {"number"}
  return false unless @writable
  return false if (x > @w) or (y > @h)
  if @buffer[x] and @buffer[x][y]
    @buffer[x][y] = nil
    @buffer[x]    = nil if 0 == table.getn @buffer[x]
  return true

-- Draws a buffer-like table onto the buffer
drawPixels = => (sx, sy, pixels) ->
  expect 1, @,      {"VBuffer"}
  expect 2, sx,     {"number"}
  expect 3, sy,     {"number"}
  expect 4, pixels, {"table"}
  return false unless @writable
  return false if (sx > @w) or (sy > @h)
  for x, row in npairs pixels
    for y, pixel in npairs row
      setPixel @, x, y, pixel

{
  :Buffer
  :resize
  :setPixel, :unsetPixel, :drawPixels
}