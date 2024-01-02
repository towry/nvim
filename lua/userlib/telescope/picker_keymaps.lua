local M = {}

function M.open_selected_in_window(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  local action_set = require('telescope.actions.set')
  local win_pick = require('window-picker')

  local picker = action_state.get_current_picker(prompt_bufnr)
  local win_picked = win_pick.pick_window({
    autoselect_one = true,
    include_current_win = false,
  })
  -- allow cancelling.
  if not win_picked then
    return
  end
  action_state
    .get_current_history()
    :append(action_state.get_current_line(), action_state.get_current_picker(prompt_bufnr))
  picker.get_selection_window = function()
    return win_picked or 0
  end
  return action_set.select(prompt_bufnr, 'default')
end

return M
