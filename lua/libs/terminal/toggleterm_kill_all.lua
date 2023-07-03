---@return boolean
local function toggleterm_kill_all()
  local terms = require('toggleterm.terminal').get_all()
  local is_shut = false
  local job_ids = {}

  for _, term in ipairs(terms) do
    --- some hack,
    --- otherwise toggleterm will try to delete buffer, close window etc, we do not want it do this at vim exit.
    term.on_exit = nil
    term.close_on_exit = false

    local ret = vim.fn.jobstop(term.job_id)
    if ret == 1 then
      table.insert(job_ids, term.job_id)
      is_shut = true
    end
  end

  if is_shut then vim.fn.jobwait(job_ids, 2000) end
  return is_shut
end


return toggleterm_kill_all
