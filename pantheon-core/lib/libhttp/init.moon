-- pantheon/core - libhttp
-- HTTP functions for the Core
-- By daelvn
config = loadConfig "kernel"
error "native http API is not enabled"   unless http
error "pantheon http API is not enabled" unless (not config) or config.http

-- Native request function
-- http.request (url, post, headers, binary, method)
natrq = http.request

-- URL Checking functions
checkURLAsync = http.checkURL
checkURL      = (url) ->
  ok, err = checkURLAsync url
  return ok, err unless ok
  while true do
    evt, eurl, eok, eerr = os.pullEvent "http_check"
    return eok, eerr if url == eurl

-- available verbs
VERBS = {"GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD", "TRACE"}

-- create native async functions
async = {}
for verb in *VERBS
  async[string.lower verb] = (url, post, headers, binary=false) ->
    expect 1, url,     {"string"},        verb
    expect 2, post,    {"string", "nil"}, verb
    expect 3, headers, {"table",  "nil"}, verb
    expect 4, binary,  {"boolean"},       verb
    post = headers if verb == "GET"
    error "invalid url '#{url}'" unless checkURL url
    --
    ok, err = natrq url, post, headers, nil, verb
    return ok, err

-- create native sync functions
sync = {}
for verb in *VERBS
  sync[string.lower verb] = (url, post, headers, binary=false) ->
    ok, err = async[string.lower verb] url, post, headers, binary
    return ok, err unless ok
    while true do
      evt, eurl, e2, e3 = os.pullEvent!
      continue unless eurl == url
      if event == "http_success"
        return e2
      elseif event == "http_failure"
        return e2, e3
    return nil, err

--> HTTPRequest structure
-- HTTPRequest {url}
--   get (headers, binary)                     -> result
--   post (body, headers, binary)              -> result
--   request (verb) -> (body, headers, binary) -> result
HTTPRequest = (url) ->
  expect 1, url, {"string"}, "HTTPRequest"
  error "invalid url '#{url}'" unless checkURL url
  return typeset {:url}, "HTTPRequest"

--> HTTPAsyncRequest structure
-- HTTPAsyncRequest {url}
--   get (headers)                     -> ok, err
--   post (body, headers)              -> ok, err
--   request (verb) -> (body, headers) -> ok, err
--   $http_success [url, body]
--   $http_failure [url, ?, ?]
HTTPAsyncRequest = (url) ->
  expect 1, url, {"string"}, "HTTPAsyncRequest"
  error "invalid url '#{url}'" unless checkURL url
  return typeset {:url}, "HTTPAsyncRequest"

-- request
_rqSync = (verb, url, body, headers, binary) ->
  error "#{verb} is not a valid http verb" unless sync[string.lower verb]
  local ret, err
  if verb == "GET"
    ret, err = sync[string.lower verb] url, nil, headers, binary
  else
    ret, err = sync[string.lower verb] url, body, headers, binary
  --
  return ret, err
_rqAsync = (verb, url, body, headers, binary) ->
  error "#{verb} is not a valid http verb" unless async[string.lower verb]
  local ret, err
  if verb == "GET"
    ret, err = async[string.lower verb] url, nil, headers, binary
  else
    ret, err = async[string.lower verb] url, body, headers, binary
  --
  return ret, err
request = (verb) -> (req) -> (body, headers, binary) ->
  expect 1, verb,    {"string"},                          "request"
  expect 2, req,     {"HTTPRequest", "HTTPAsyncRequest"}, "request"
  expect 3, body,    {"string",      "nil"},              "request"
  expect 4, headers, {"table",       "nil"},              "request"
  expect 5, binary,  {"boolean"},                         "request"
  switch typeof req
    when "HTTPRequest"      then _rqSync  verb, req.url, body, headers
    when "HTTPAsyncRequest" then _rqAsync verb, req.url, body, headers

-- get & post
get  = request "GET"
post = request "POST"

-- Shortcuts
requestURL      = (verb) -> (url) -> (request verb) HTTPRequest url
requestAsyncURL = (verb) -> (url) -> (request verb) HTTPAsyncRequest url
getURL          = (url) -> get HTTPRequest url
postURL         = (url) -> post HTTPRequest url

-- Set globals
http.get     = getURL
http.post    = postURL
http.request = (url, body, headers, binary, verb) -> ((requestURL verb) url) body, headers, binary

-- return
{
  :HTTPRequest, :HTTPAsyncRequest
  :request,     :get, :post
  :requestURL,  :requestAsyncURL
  :getURL,      :postURL
}