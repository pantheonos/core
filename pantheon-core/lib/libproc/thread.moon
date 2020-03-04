-- pantheon/libproc.thread
-- Thread management for libproc
-- By daelvn

-- Generates a new UID
uid    = 0
newUID = ->
  uid += 1
  uid

-- A state is a collection of Threads
State = ->
  this = {
    list:  {} -- list of processes by uid
    order: {} -- running list of uids
  }
  --
  setmetatable this, {
    -- if index is number, get from proc list
    __index: (i) => switch type i
      when "number" then return (rawget @, "list")[i]
      else               return rawget @, i
    -- if newindex is number, set to proc list
    __newindex: (i, v) => switch type i
      when "number" then (rawget @, "list")[i] = v
      else               rawset @, i, v
  }
  --
  return typeset this, "State"

-- Creates a new thread
--   thread.priority: Value 0-5
--                    Higher value gets run earlier
Thread = (fn) ->
  expect 1, fn, {"string", "function"}
  -- Create object
  this = typeset {}, "Thread"
  -- Set @fn
  switch type fn
    when "string"
      -- Load from file
      this.source = fn
      this.fn     = loadfile fn
    when "function"
      this.source = "(function)"
      this.fn     = fn
  -- Create coroutine
  this.task = coroutine.create fn
  -- Others
  this.uid      = newUID!
  this.children = {}
  this.priority = 0       -- from 0 to 5, the higher the earlier it is run
  this.status   = "alive" -- alive | disabled | dead
  -- Return
  return this

-- Resumes a thread
resume = (thread, ...) ->
  expect 1, thread, {"Thread"}
  return coroutine.resume thread.task, ...

-- Selects a thread from a state
select = (state, uid) ->
  expect 1, state, {"State"}
  expect 2, uid,   {"number"}
  return state[uid]

-- Kills a process in a state
kill = (state, uid) ->
  expect 1, state, {"State"}
  expect 2, uid,   {"number"}
  if state[uid]
    state[uid] = false
    return true
  else return false

-- Adds a thread into a state
enlist = (state, thread) ->
  expect 1, state,  {"State"}
  expect 2, thread, {"Thread"}
  thread.state      = state
  state[thread.uid] = thread
  return state

-- Reorders priority in a state
reorder = (state) ->
  expect 1, state, {"State"}
  table.sort state.order, (a, b) -> state[a].priority > state[b].priority
  state.order = [uid for uid in *state.order when not state[uid].disabled]
  return state

-- Changes the priority of a thread
setPriority = (thread, priority=1) ->
  expect 1, thread,   {"Thread"}
  expect 2, priority, {"number"}
  if (priority < 0) or (priority > 5)
    error "Priority must be between 0 and 5"
  thread.priority = priority
  reorder thread.state if thread.state
  return thread

{
  :Thread, :State
  :newUID
  :select, :resume, :kill
  :enlist, :reorder, :setPriority
}