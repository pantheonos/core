-- pantheon/libproc
-- Process manager for Pantheon
-- By daelvn
import Thread, State,
       select, resume, kill, enlist, reorder,
       setPriority
       from require "libproc.thread"

-- Create process list
procl = State!

-- Runs all of the processes in a state once
runAll = (state) ->
  expect 1, state, {"State"}
  -- First of all, reorder the state
  reorder state
  -- Then, run all coroutines
  for uid in *state.order
    resume select state, uid

-- Actual running loop
run = -> while true do runAll procl

{
  :procl, :runAll, :run
}