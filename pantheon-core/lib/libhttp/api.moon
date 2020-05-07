-- pantheon/libhttp.api
-- Represent a RESTy API as a Lua table
-- By daelvn
import encode, decode from require "json"
nap                      = require "libhttp.nap"

contentFor = (opt={}) -> (napcall) ->
  -- get content
  content = napcall\readAll!
  napcall\close!
  -- return content
  if opt.json
    return decode content
  else
    return content

GET = (t) ->
  t.method = "GET"
  t

POST = (t) ->
  t.method = "POST"
  t

{ :contentFor, :GET, :POST }