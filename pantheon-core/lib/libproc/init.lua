local Thread, State, select, resume, kill, enlist, reorder, setPriority
do
  local _obj_0 = require("libproc.thread")
  Thread, State, select, resume, kill, enlist, reorder, setPriority = _obj_0.Thread, _obj_0.State, _obj_0.select, _obj_0.resume, _obj_0.kill, _obj_0.enlist, _obj_0.reorder, _obj_0.setPriority
end
local procl = State()
local runAll
runAll = function(state)
  expect(1, state, {
    "State"
  })
  reorder(state)
  local _list_0 = state.order
  for _index_0 = 1, #_list_0 do
    local uid = _list_0[_index_0]
    resume(select(state, uid))
  end
end
local run
run = function()
  while true do
    runAll(procl)
  end
end
return {
  procl = procl,
  runAll = runAll,
  run = run
}
