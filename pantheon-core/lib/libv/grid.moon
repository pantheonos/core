-- pantheon/libv.grid
-- Absolute positioning in libv
-- By daelvn

-- Creates a new Grid with a fixed width and height
Grid = (w, h) ->
  expect 1, w, {"number"}, "Grid"
  expect 2, h, {"number"}, "Grid"
  this = typeset { :w, :h, references: {} }, "VGrid"
  return this

-- Creates a new reference on a Grid
-- 'd' is the depth of the reference, to order results. 
Reference = (grid) -> (x, y, d, buffer) ->
  expect 1, grid, {"VGrid"}, "Reference"
  expect 2, x, {"number"}, "Reference"
  expect 3, y, {"number"}, "Reference"
  expect 4, d, {"number"}, "Reference"
  expect 5, buffer, {"VBuffer"}, "Reference"
  error "x must be above 0" if x < 1
  error "y must be above 0" if y < 1
  grid.references["#{x},#{y},#{d}"] = buffer

-- Moves a reference
moveReference = (grid) -> (oxyd, xyd) ->
  expect 1, grid, {"VGrid"}, "moveReference"
  expect 2, oxyd, {"table"}, "moveReference"
  expect 3, xyd, {"table"}, "moveReference"
  return false unless grid.references["#{oxyd.x},#{oxyd.y},#{oxyd.d}"].movable
  return false unless grid.references["#{oxyd.x},#{oxyd.y},#{oxyd.d}"]
  grid.references["#{xyd.x},#{xyd.y},#{xyd.d}"]    = grid.references["#{oxyd.x},#{oxyd.y},#{oxyd.d}"]
  grid.references["#{oxyd.x},#{oxyd.y},#{oxyd.d}"] = nil

-- Returns the buffer for a reference
getReference = (grid) -> (x, y, d) ->
  expect 1, grid, {"VGrid"}, "getReference"
  expect 2, x, {"number"}, "getReference"
  expect 3, y, {"number"}, "getReference"
  expect 4, d, {"number"}, "getReference"
  return grid.references["#{x},#{y},#{d}"]

-- Given a string "x,y,d", returns x, y and d separately as numbers
pointFor = (xyd) ->
  expect 1, xyd, {"string"}, "pointFor"
  x, y, d = xyd\match "(%d+),(%d+),(%d+)"
  return (tonumber x), (tonumber y), (tonumber d)

-- Given an absolute position on a grid, returns a list of buffers referenced
-- that intersect with the point, and the positions relative to 1,1 on the Grid.
getIntersecting = (grid) -> (x, y) ->
  expect 1, grid, {"VGrid"}, "getIntersecting"
  expect 2, x,    {"number"}, "getIntersecting"
  expect 3, y,    {"number"}, "getIntersecting"
  intersecting = {}
  for point, buf in pairs grid.references
    px, py, pd = pointFor point
    -- since buffers are referenced as Buffer[1,1] = Grid[x,y]
    -- we know that references greater than our point will not
    -- show up.
    continue if (px > x) or (py > y)
    intersecting[pd] = {gx: x, gy: y, bx: x-px, by: y-py, buffer: buf}
  return intersecting
  
{
  :Grid, :Reference
  :moveReference, :getReference
  :pointFor, :getIntersecting
}
