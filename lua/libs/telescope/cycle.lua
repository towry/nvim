--- taken from https://github.com/lucc/vim-config/blob/4c018d5ec2f86e65668ad33aa6f746310d3d9137/lua/telescope/cycle.lua
local builtin = require "telescope.builtin"
local state = require "telescope.actions.state"

-- create a new cycle picker with the given pickers to cycle trough
return function(...)
  local pickers = { ... }
  if #pickers == 0 then
    error("empty list of pickers given")
  end

  -- although lua tables are indexed from 1 one start with 0 because it is
  -- easier to do the modulo stuff 0 based and just add 1 when accessing the
  -- table.
  local index = 0

  -- the picker object we will return
  local cycle = {}
  function cycle.cycle(step)
    step = step or 1
    index = (index + step) % #pickers
    pickers[index + 1] { default_text = state.get_current_line() }
  end

  function cycle.next() cycle.cycle(1) end

  function cycle.previous() cycle.cycle(-1) end

  -- return a dynamically created cycle picker with the given pickers
  return setmetatable(cycle, {
    __call = function(opts)
      index = 0
      pickers[index + 1](opts)
    end
  })
end
