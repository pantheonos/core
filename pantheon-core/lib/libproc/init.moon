-- pantheon/libproc
-- Process manager for Pantheon
-- By daelvn
raisin = require "raisin"

-- Generates a new UID
_uid    = 0
newUID = ->
  _uid += 1
  _uid

-- A State is a collection of Threads
State = (name, priority=0) ->
  expect 1, name, {"string"}, "State"
  expect 2, priority, {"number"}, "State"
  -- Create object
  this = typeset {
    instance: raisin.group priority
    threads:  {}
    :name
  }, "State"
  return this

-- A Thread is an object that contains a raisin thread
Thread = (state) -> (fn, priority=0, uid=newUID!) ->
  expect 1, state, {"State"}, "Thread"
  expect 2, fn, {"function"}, "Thread"
  expect 3, priority, {"number"}, "Thread"
  expect 4, uid, {"number"}, "Thread"
  -- Check that the UID was not previously registered
  if state.threads[uid]
    error "#{state.name}/#{uid} already exists."
  -- Create object
  this = typeset {
    instance: raisin.thread fn, priority, state.instance
    :fn
    :priority
    :uid
  }, "Thread"
  -- Register object
  state.threads[uid] = this
  -- Return
  return this

-- Runs all threads in a State
runState = (state) ->
  expect 1, state, {"State"}, "runState"
  raisin.manager.runGroup state.instance

-- Halts all management
haltAll = raisin.manager.halt

-- Gets the status of a Thread or State
statusOf = (any) ->
  expect 1, any, {"Thread", "State"}, "statusOf"
  return any.instance\state!

-- Enables a Thread or State
enable = (any) ->
  expect 1, any, {"Thread", "State"}, "enable"
  any.instance\toggle true

-- Disables a Thread or State
disable = (any) ->
  expect 1, any, {"Thread", "State"}, "disable"
  any.instance\toggle false

-- Gets the priority of a Thread or State
priorityOf = (any) ->
  expect 1, any, {"Thread", "State"}, "priorityOf"
  return any.instance\getPriority!

-- Sets the priority of a Thread or State
setPriority = (any) -> (priority=0) ->
  expect 1, any, {"Thread", "State"}, "setPriority"
  expect 2, priority, {"number"}, "setPriority"
  return any.instance\setPriority priority

-- Removes the Thread or State from memory.
remove = (any) ->
  expect 1, any, {"Thread", "State"}, "remove"
  return any.instance\remove!

-- Finds a thread in a certain state
find = (state) -> (pat) ->
  expect 1, state, {"State"},  "find"
  expect 2, pat,   {"string"}, "find"
  results = {}
  for thread in *state.threads
    if thread\match pat
      table.insert results, thread
  return table.unpack results

-- Return all
{
  :newUID
  :State, :Thread
  :runState, :haltAll
  :priorityOf, :statusOf
  :setPriority, :enable, :disable, :remove, :find
}