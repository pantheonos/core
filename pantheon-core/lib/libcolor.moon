-- pantheon/libcolor
-- List of colors and modifying functions
-- By daelvn
import band, rshift, lshift from bit32

-- List of default colors
colors = {
  [2^0]:  "white"
  [2^1]:  "orange"
  [2^2]:  "magenta"
  [2^3]:  "lightBlue"
  [2^4]:  "yellow"
  [2^5]:  "lime"
  [2^6]:  "pink"
  [2^7]:  "gray"
  [2^8]:  "lightGray"
  [2^9]:  "cyan"
  [2^10]: "purple"
  [2^11]: "blue"
  [2^12]: "brown"
  [2^13]: "green"
  [2^14]: "red"
  [2^15]: "black"
}
for k, v in pairs colors do colors[v] = k
colors.grey      = colors.gray
colors.lightGrey = colors.lightGray

-- Converts from Hex to RGB
hexToRGB = (hex) ->
  expect 1, hex, {"number"}, "hexToRGB"
  r = (band (rshift hex, 16), 0xFF) / 255
  g = (band (rshift hex, 8),  0xFF) / 255
  b = (band hex,              0xFF) / 255
  return {:r, :g, :b}

-- Converts from RGB to Hex
-- Components must be in range 0-255
RGBToHex = (r, g, b) ->
  expect 1, r, {"number"}, "RGBToHex"
  expect 2, g, {"number"}, "RGBToHex"
  expect 3, b, {"number"}, "RGBToHex"
  rh = lshift (band r, 0xFF), 16
  gh = lshift (band g, 0xFF), 8
  bh =         band b, 0xFF
  return rh+gh+bh

-- Creates a new color
-- Name is optional
-- Color 0xFF0000
-- Color 255, 0, 0
Color = (r, g, b, name="") ->
  local color
  if b
    expect 1, r, {"number"}, "Color"
    expect 2, g, {"number"}, "Color"
    expect 3, b, {"number"}, "Color"
    expect 4, name, {"string"}, "Color"
    color = {:name, :r, :g, :b}
  else
    expect 1, r, {"number"}, "Color"
    expect 2, g, {"string"}, "Color"
    color      = {hexToRGB r}
    color.name = g
  return typeset color, "Color"

-- Creates a new color index
-- (2^i) where i is between 0 and 15
-- i where i is between 0 and 255
ColorIndex = (idx, gfx=false) ->
  expect 1, idx, {"number"}, "ColorIndex"
  expect 2, gfx, {"boolean"}, "ColorIndex"
  index = typeset { :gfx, value: 0 }, "ColorIndex"
  if gfx
    error "Invalid index #{idx}" if (idx < 0) or (idx > 255)
    index.value = idx
  else
    error "Invalid index #{2^idx}" if (idx < 0) or (idx > 15)
    index.value = 2^idx
  return index

-- Gets the i from 2^i
toI = (num) ->
  expect 1, num, {"number"}, "toI"
  total = 0
  while num > 0 do
    return total if (num % 2) != 0
    num   /= 2
    total += 1

-- Creates a new palette
Palette = (name) -> typeset {:name, colors: {}}, "Palette"

-- Adds a color to a palette
addColor = (pal) -> (idx, clr) ->
  expect 1, pal, {"Palette"}, "addColor"
  expect 2, idx, {"ColorIndex"}, "addColor"
  expect 3, clr, {"Color"}, "addColor"
  pal.colors[idx.value] = clr
  pal.colors[clr.name]  = clr
  return pal

-- Removes a color from a palette by index
removeColor = (pal) -> (idx) ->
  expect 1, pal, {"Palette"}, "removeColor"
  expect 2, idx, {"ColorIndex"}, "removeColor"
  error "Color #{idx.value} in #{pal.name} not found" unless pal.colors[idx.value]
  clr                   = pal.colors[idx.value]
  pal.colors[clr.name]  = nil
  pal.colors[idx.value] = nil
  return clr

-- Applies a palette
apply = (pal) ->
  expect 1, pal, {"Palette"}, "apply"
  if term.getGraphicsMode
    switch term.getGraphicsMode!
      when 0, 1
        for i=1, 16
          term.setPaletteColor 2^(i-1), pal.colors[i] if pal.colors[i]
      when 2
        for i=1, 256
          term.setPaletteColor i-1, pal.colors[i] if pal.colors[i]
  else
    for i=1, 16
      term.setPaletteColor 2^(i-1), pal.colors[i] if pal.colors[i]

-- Default CC palette
default = Palette "default"
default.colors = {
  [1]:  Color 0x1,    "white"
  [2]:  Color 0x2,    "orange"
  [3]:  Color 0x4,    "magenta"
  [4]:  Color 0x8,    "lightBlue"
  [5]:  Color 0x10,   "yellow"
  [6]:  Color 0x20,   "lime"
  [7]:  Color 0x40,   "pink"
  [8]:  Color 0x80,   "gray"
  [9]:  Color 0x100,  "lightGray"
  [10]: Color 0x200,  "cyan"
  [11]: Color 0x400,  "purple"
  [12]: Color 0x800,  "blue"
  [13]: Color 0x1000, "brown"
  [14]: Color 0x2000, "green"
  [15]: Color 0x4000, "red"
  [16]: Color 0x8000, "black"
}
for k, v in pairs default.colors do default.colors[v.name] = v

{
  :Color, :ColorIndex, :Palette
  :addColor, :removeColor, :apply
  :colors, :default
  :toI
}