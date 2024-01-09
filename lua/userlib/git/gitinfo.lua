local M = {}

-- ms
M.interval = 2 * 1000
M.ticks = 0
---@type vim.uv.Timer?
M.timer = nil
M.loading = false

M.gitinfo = {
  untracked = 0,
  unstaged = 0,
}

---
function M.update()
  if M.timer == nil then
    return
  end
  if M.loading then
    return
  end
end

function M.start()
  if M.timer then
    return
  end

  M.timer = vim.uv.new_timer()
  M.timer:start(0, M.interval, vim.schedule_wrap(M.update))
end

function M.stop()
  if M.timer == nil then
    return
  end
  vim.schedule(function()
    if not M.timer then
      return
    end
    M.timer:stop()
    M.timer = nil
  end)
end

return M
