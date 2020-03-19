local band, rshift, lshift
do
  local _obj_0 = bit32
  band, rshift, lshift = _obj_0.band, _obj_0.rshift, _obj_0.lshift
end
local colors = {
  [2 ^ 0] = "white",
  [2 ^ 1] = "orange",
  [2 ^ 2] = "magenta",
  [2 ^ 3] = "lightBlue",
  [2 ^ 4] = "yellow",
  [2 ^ 5] = "lime",
  [2 ^ 6] = "pink",
  [2 ^ 7] = "gray",
  [2 ^ 8] = "lightGray",
  [2 ^ 9] = "cyan",
  [2 ^ 10] = "purple",
  [2 ^ 11] = "blue",
  [2 ^ 12] = "brown",
  [2 ^ 13] = "green",
  [2 ^ 14] = "red",
  [2 ^ 15] = "black"
}
for k, v in pairs(colors) do
  colors[v] = k
end
colors.grey = colors.gray
colors.lightGrey = colors.lightGray
local hexToRGB
hexToRGB = function(hex)
  expect(1, hex, {
    "number"
  })
  local r = (band((rshift(hex, 16)), 0xFF)) / 255
  local g = (band((rshift(hex, 8)), 0xFF)) / 255
  local b = (band(hex, 0xFF)) / 255
  return {
    r = r,
    g = g,
    b = b
  }
end
local RGBToHex
RGBToHex = function(r, g, b)
  expect(1, r, {
    "number"
  })
  expect(2, g, {
    "number"
  })
  expect(3, b, {
    "number"
  })
  local rh = lshift((band(r, 0xFF)), 16)
  local gh = lshift((band(g, 0xFF)), 8)
  local bh = band(b, 0xFF)
  return rh + gh + bh
end
local Color
Color = function(r, g, b, name)
  if name == nil then
    name = ""
  end
  local color
  if b then
    expect(1, r, {
      "number"
    })
    expect(2, g, {
      "number"
    })
    expect(3, b, {
      "number"
    })
    expect(4, name, {
      "string"
    })
    color = {
      name = name,
      r = r,
      g = g,
      b = b
    }
  else
    expect(1, r, {
      "number"
    })
    expect(2, g, {
      "string"
    })
    color = {
      hexToRGB(r)
    }
    color.name = g
  end
  return typeset(color, "Color")
end
local ColorIndex
ColorIndex = function(idx, gfx)
  if gfx == nil then
    gfx = false
  end
  expect(1, idx, {
    "number"
  })
  expect(2, gfx, {
    "boolean"
  })
  local index = typeset({
    gfx = gfx,
    value = 0
  }, "ColorIndex")
  if gfx then
    if (idx < 0) or (idx > 255) then
      error("Invalid index " .. tostring(idx))
    end
    index.value = idx
  else
    if (idx < 0) or (idx > 15) then
      error("Invalid index " .. tostring(2 ^ idx))
    end
    index.value = 2 ^ i
  end
  return index
end
local toI
toI = function(num)
  expect(1, num, {
    "number"
  })
  local total = 0
  while num > 0 do
    if (num % 2) ~= 0 then
      return total
    end
    num = num / 2
    total = total + 1
  end
end
local Palette
Palette = function(name)
  return typeset({
    name = name,
    colors = { }
  }, "Palette")
end
local addColor
addColor = function(pal)
  return function(idx, clr)
    expect(1, pal, {
      "Palette"
    })
    expect(2, idx, {
      "ColorIndex"
    })
    expect(3, clr, {
      "Color"
    })
    pal.colors[idx.value] = clr
    pal.colors[clr.name] = clr
    return pal
  end
end
local removeColor
removeColor = function(pal)
  return function(idx)
    expect(1, pal, {
      "Palette"
    })
    expect(2, idx, {
      "ColorIndex"
    })
    if not (pal.colors[idx.value]) then
      error("Color " .. tostring(idx.value) .. " in " .. tostring(pal.name) .. " not found")
    end
    local clr = pal.colors[idx.value]
    pal.colors[clr.name] = nil
    pal.colors[idx.value] = nil
    return clr
  end
end
local apply
apply = function(pal)
  expect(1, pal, {
    "Palette"
  })
  if term.getGraphicsMode then
    local _exp_0 = term.getGraphicsMode()
    if 0 == _exp_0 or 1 == _exp_0 then
      for i = 1, 16 do
        if pal.colors[i] then
          term.setPaletteColor(2 ^ (i - 1), pal.colors[i])
        end
      end
    elseif 2 == _exp_0 then
      for i = 1, 256 do
        if pal.colors[i] then
          term.setPaletteColor(i - 1, pal.colors[i])
        end
      end
    end
  else
    for i = 1, 16 do
      if pal.colors[i] then
        term.setPaletteColor(2 ^ (i - 1), pal.colors[i])
      end
    end
  end
end
local default = Palette("default")
default.colors = {
  [1] = Color(0x1, "white"),
  [2] = Color(0x2, "orange"),
  [3] = Color(0x4, "magenta"),
  [4] = Color(0x8, "lightBlue"),
  [5] = Color(0x10, "yellow"),
  [6] = Color(0x20, "lime"),
  [7] = Color(0x40, "pink"),
  [8] = Color(0x80, "gray"),
  [9] = Color(0x100, "lightGray"),
  [10] = Color(0x200, "cyan"),
  [11] = Color(0x400, "purple"),
  [12] = Color(0x800, "blue"),
  [13] = Color(0x1000, "brown"),
  [14] = Color(0x2000, "green"),
  [15] = Color(0x4000, "red"),
  [16] = Color(0x8000, "black")
}
for k, v in pairs(default.colors) do
  default.colors[v.name] = v
end
return {
  Color = Color,
  ColorIndex = ColorIndex,
  Palette = Palette,
  addColor = addColor,
  removeColor = removeColor,
  apply = apply,
  colors = colors,
  default = default,
  toI = toI
}
