local uid = 0
local newUID
newUID = function()
  uid = uid + 1
  return uid
end
local State
State = function()
  local this = {
    list = { },
    order = { }
  }
  setmetatable(this, {
    __index = function(self, i)
      local _exp_0 = type(i)
      if "number" == _exp_0 then
        return (rawget(self, "list"))[i]
      else
        return rawget(self, i)
      end
    end,
    __newindex = function(self, i, v)
      local _exp_0 = type(i)
      if "number" == _exp_0 then
        (rawget(self, "list"))[i] = v
      else
        return rawset(self, i, v)
      end
    end
  })
  return typeset(this, "State")
end
local Thread
Thread = function(fn)
  expect(1, fn, {
    "string",
    "function"
  })
  local this = typeset({ }, "Thread")
  local _exp_0 = type(fn)
  if "string" == _exp_0 then
    this.source = fn
    this.fn = loadfile(fn)
  elseif "function" == _exp_0 then
    this.source = "(function)"
    this.fn = fn
  end
  this.task = coroutine.create(fn)
  this.uid = newUID()
  this.children = { }
  this.priority = 0
  this.status = "alive"
  return this
end
local resume
resume = function(thread, ...)
  expect(1, thread, {
    "Thread"
  })
  return coroutine.resume(thread.task, ...)
end
local select
select = function(state, uid)
  expect(1, state, {
    "State"
  })
  expect(2, uid, {
    "number"
  })
  return state[uid]
end
local kill
kill = function(state, uid)
  expect(1, state, {
    "State"
  })
  expect(2, uid, {
    "number"
  })
  if state[uid] then
    state[uid] = false
    return true
  else
    return false
  end
end
local enlist
enlist = function(state, thread)
  expect(1, state, {
    "State"
  })
  expect(2, thread, {
    "Thread"
  })
  thread.state = state
  state[thread.uid] = thread
  return state
end
local reorder
reorder = function(state)
  expect(1, state, {
    "State"
  })
  table.sort(state.order, function(a, b)
    return state[a].priority > state[b].priority
  end)
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = state.order
    for _index_0 = 1, #_list_0 do
      local uid = _list_0[_index_0]
      if not state[uid].disabled then
        _accum_0[_len_0] = uid
        _len_0 = _len_0 + 1
      end
    end
    state.order = _accum_0
  end
  return state
end
local setPriority
setPriority = function(thread, priority)
  if priority == nil then
    priority = 1
  end
  expect(1, thread, {
    "Thread"
  })
  expect(2, priority, {
    "number"
  })
  if (priority < 0) or (priority > 5) then
    error("Priority must be between 0 and 5")
  end
  thread.priority = priority
  if thread.state then
    reorder(thread.state)
  end
  return thread
end
return {
  Thread = Thread,
  State = State,
  newUID = newUID,
  select = select,
  resume = resume,
  kill = kill,
  enlist = enlist,
  reorder = reorder,
  setPriority = setPriority
}
