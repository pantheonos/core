-- pantheon/core - /bin/procd
-- Process daemon for Pantheon
-- Handles crashes, generates logs and such.
-- By daelvn
import tempFilename, writeTo from require "libc.io"
libproc = require "libproc"
echo    = kdprint "procd"

-- Create PROC_MAIN State
import State, Thread from libproc
echo "creating PROC_MAIN state"
export PROC_MAIN = State "PROC_MAIN", 1
newThread        = Thread PROC_MAIN

-- Select utility
selectl = (n, ...) ->
  argl, toRet = {...}, {}
  for i=1, n
    toRet[i] = table.remove argl, 1
  table.insert toRet, argl
  return table.unpack toRet

-- Function to generate logs
newLog = (name, uid, txt, filename=(tempFilename "/tmp/#{fs.getName name}-#{uid}-")) ->
  writeTo filename, txt

-- Set UIDs to GC
GC_ON = {}
collectGarbage = (state) -> ->
  expect 1, state, {"State"}, "collectGarbage"
  for uid in *GC_ON
    state.threads[uid] = nil
    coroutine.yield!

-- Add the garbage collector as a thread
newThread (collectGarbage PROC_MAIN), 3, -1 -- special UID -1 with priority 3

-- Call function
import newUID, disable from libproc
export call = (name, fn, priority=0, uid=newUID!) ->
  expect 1, name,     {"string"},   "call"
  expect 2, fn,       {"function"}, "call"
  expect 3, priority, {"number"},   "call"
  expect 4, uid,      {"number"},   "call"
  --
  fc = (...) ->
    echo "switching to thread #{name}##{uid}"
    args     = {...}
    ok, errt = selectl 1, pcall -> fn table.unpack args
    if ok
      return table.unpack errt
    else
      err = "#{name}##{uid}: #{errt[1]}"
      log = tempFilename "/tmp/#{fs.getName name}-#{uid}-"
      kprint "!! #{name}##{uid} crashed and had to stop"
      echo   "dumping log at #{log}"
      newLog name, uid, err, log
      echo   "stopping thread"
      disable PROC_MAIN.threads[uid]
  --
  return newThread fc, priority, uid

-- callFile
export callFile = (name, priority=0, uid=newUID!) -> call name, (loadfile name), priority, uid

-- Table of threads
export PROC_THREADS = PROC_MAIN.threads

-- Runs the state
import runState from libproc
runProcd = -> runState PROC_MAIN

{ :runProcd }