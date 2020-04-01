-- pantheon/libhttp.server
-- HTTP listening functions
-- By daelvn
config = loadConfig "kernel"
error "native http API is not enabled"   unless http
error "pantheon http API is not enabled" unless (not config) or config.http

-- Starts listening for events on a port
listen = (port) -> http.addListener port
-- Stops listening for events on a port
deafen = (port) -> http.removeListener port

-- Continue value
HTTP_CONTINUE = typeset {}, "HTTP_CONTINUE"

--> HTTPServerRequest structure
-- HTTPServerRequest {endpoint, method, headers, handle}
--   read (length) -> data
--   close () -> ?
HTTPServerRequest = (handle) ->
  endpoint = handle.getURL!
  method   = handle.getMethod!
  headers  = handle.getResponseHeaders!
  expect 1, endpoint, {"string"}, "HTTPServerRequest"
  expect 2, method,   {"string"}, "HTTPServerRequest"
  expect 3, headers,  {"table"},  "HTTPServerRequest"
  return typeset {:endpoint, :method, :headers, :handle}, "HTTPServerRequest"

-- read
read = (req) -> (length) ->
  expect 1, req,    {"HTTPServerRequest"}, "read"
  expect 2, length, {"number", "string"},  "read"
  return req.handle.read length

--> HTTPServerResponse structure
-- HTTPServerResponse {status, headers, handle}
--   write (data) -> ?
--   close () -> ?
HTTPServerResponse = (handle) -> typeset {status: 200, headers: {}, :handle}, "HTTPServerResponse"

-- write data
write = (req) -> (data) ->
  expect 1, req, {"HTTPServerResponse"}, "write"
  req.write data

-- close
close = (req) ->
  expect 1, req, {"HTTPServerRequest", "HTTPServerResponse"}, "close"
  req.close!

--> HTTPServer structure
-- HTTPServer {port}
--   addCallback (fn) -> nil
--   start () -> nil
--   stop () -> nil
--   $http_request [port, ihandle, ohandle]
--   $server_stop []
------
-- If the callback returns:
--   HTTPServerResponse - returns response
--   HTTP_CONTINUE      - goes to next callback
--   false, nil         - stops server
--   (other)            - stops server
HTTPServer = (port) ->
  expect 1, port, {"number"}, "HTTPServer"
  --
  return typeset {:port, callbacks: {}}, "HTTPServer"

-- adds a new callback
addCallback = (server) -> (fn) ->
  expect 1, server, {"HTTPServer"}, "addCallback"
  expect 2, fn,     {"function"},   "addCallback"
  table.insert server.callbacks, fn

-- stops all servers
stopAll = -> os.queueEvent "server_stop"

-- stops a certain server
stop = (server) ->
  expect 1, server, {"HTTPServer"}, "addCallback"
  os.queueEvent "server_stop", server.port

-- starts the server
start = (server) ->
  expect 1, server, {"HTTPServer"}, "addCallback"
  --
  listen server.port
  while true
    ev, eport, eih, eoh = os.pullEvent!
    switch ev
      when "server_stop"
        if eport
          kprint "Stopping server at port #{server.port}! (manual termination)"
          deafen server.port if eport == server.port
          break
        else
          kprint "Stopping server at port #{server.port}! (global termination)"
          deafen server.port
          break
      when "http_request"
        continue unless eport == server.port
        ih = HTTPServerRequest eih
        oh = HTTPServerResponse eoh
        for cb in *server.callbacks
          if x = cb ih, oh
            if "HTTPServerResponse" == typeof x
              x.handle.setStatusCode x.status
              for k, v in pairs x.headers
                x.handle.setResponseHeader k, v
              x.close!
            elseif "HTTP_CONTINUE" == typeof x
              continue
            else
              kprint "Stopping server at port #{server.port}! (non-response return)"
              deafen server.port
              break
          else
            kprint "Stopping server at port #{server.port}! (callback termination)"
            deafen server.port
            break

-- Returns a valid callback
-- Routes get a function and remove the need for method, uri and handle checking.
-- They support :[a-z] variables and * globbing.
-----
--     Route "GET", "/api/:username", (body) => 200, @username, {Header: val}
Route = (method, endpoint, fn) -> (i, o) ->
  if i.method == method
    variables = {}
    endpoint  = endpoint\gsub "%*", "[^/]+"
    endpoint  = endpoint\gsub ":([a-z]+)", (varname) ->
      table.insert variables, varname
      "([^/]+)"
    results = {i.endpoint\match endpoint}
    if #results == 0
      -- uri doesnt match
      return HTTP_CONTINUE
    else
      -- uri matches, get variables
      zipped = {}
      if #variables > 0
        for i=1, #results do zipped[variables[i]] = results[i]
      -- call our fn
      code, body, headers = fn zipped, ((read i) "*a")
      o.status  = code or 200
      (write o) body or ""
      o.headers = headers or {}
      return o
  else return HTTP_CONTINUE

{
  :HTTP_CONTINUE
  :HTTPServer, :HTTPServerRequest, :HTTPServerResponse, :Route
  :listen, :deafen
  :addCallback, :start, :stop, :stopAll
  :read, :write, :close
}