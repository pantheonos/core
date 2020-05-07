-- pantheon/libhttp.websocket
-- WS support for Pantheon
-- By daelvn
config = loadConfig "kernel"
error "native http API is not enabled"   unless http
error "pantheon http API is not enabled" unless (not config) or config.http

natws = http.websocket

--> WebsocketAsync structure
-- WebsocketAsync {url}
--   open (headers, binary) -> ?
--   send (data) -> nil
--   receive () -> data
--   $websocket_success [url, ws]
--   $websocket_failure [url]
WebsocketAsync = (url) ->
  expect 1, url, {"string"}, "WebsocketAsync"
  return typeset {:url}, "WebsocketAsync"

--> Websocket structure
-- Websocket {url}
--   open (headers, binary) -> ?
--   send (data) -> nil
--   receive () -> data
Websocket = (url) ->
  expect 1, url, {"string"}, "Websocket"
  return typeset { :url }, "Websocket"

-- wraps a websocket handle in a websocket object
wrap = (ws) -> (handle) -> ws.socket = handle

-- open
open = (ws) -> (headers, binary=false) ->
  expect 1, ws,      {"Websocket", "WebsocketAsync"}, "open"
  expect 2, headers, {"table"},                       "open"
  expect 3, binary,  {"boolean"},                     "open"
  --
  ws.binary = binary
  ok, err   = natws ws.url, headers, binary
  return ok, err if     "WebsocketAsync" == typeof ws
  return ok, err unless ok
  --
  local wsh
  while true
    evt, eurl, ews = os.pullEvent!
    continue unless eurl == url
    if "websocket_success" == evt
      wsh = ews
    elseif "websocket_failure"
      return nil, ews
  --
  (wrap ws) wsh
  return ws

-- close
close = (ws) ->
  expect 1, ws, {"Websocket", "WebsocketAsync"}, "close"
  ws.socket.close!

-- send
send = (ws) -> (data) ->
  expect 1, ws,   {"Websocket", "WebsocketAsync"}, "close"
  expect 2, data, {"string"},                      "close"
  ws.socket.send data

-- receive
receive = (ws) ->
  expect 1, ws,   {"Websocket", "WebsocketAsync"}, "close"
  ws.socket.receive!

{
  :WebsocketAsync, :Websocket
  :wrap, :open, :close, :send, :receive
}