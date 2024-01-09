local M = {}

-- ms
M.interval = 4 * 1000
M.ticks = 0
---@type vim.uv.Timer?
M.timer = nil
M.loading = false

M.gitinfo = {
  untracked = 0,
  unstaged = 0,
  aheads = 0,
  behinds = 0,
}

--- debug
_G.gitinfo = function()
  vim.print(M.gitinfo)
end

--- gather gitinfo by using vim.system and git command
function M.update()
  if M.timer == nil then
    return
  end
  if M.loading then
    return
  end

  --
  M.loading = true
  local cmd = {
    'git',
    'status',
    '--porcelain',
    '--branch',
    '--ahead-behind',
  }

  local on_exit = function(obj)
    M.loading = false
    if obj.code ~= 0 then
      -- failed
      return
    end

    local output = obj.stdout
    --- output is string
    if type(output) == 'string' then
      output = vim.split(output, '\n')
    end

    local untracked = 0
    local unstaged = 0
    local aheads = 0
    local behinds = 0

    for _, line in ipairs(output) do
      if line:find('^%?') then
        untracked = untracked + 1
      elseif
        line:find('^M')
        or line:find('^A')
        or line:find('^D')
        or line:find('^R')
        or line:find('^C')
        or line:find('^U')
      then
        unstaged = unstaged + 1
      else
        local ahead = line:match('%[ahead%s+(%d+)%]')
        local behind = line:match('%[behind%s+(%d+)%]')
        if ahead then
          aheads = aheads + tonumber(ahead)
        end
        if behind then
          behinds = behinds + tonumber(behind)
        end
      end
    end

    M.gitinfo.untracked = untracked
    M.gitinfo.unstaged = unstaged
    M.gitinfo.aheads = aheads
    M.gitinfo.behinds = behinds
  end

  vim.system(cmd, {}, on_exit)
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

function M.running()
  return M.timer ~= nil
end

--- simple detect
function M.util_is_git_repo()
  return vim.b.gitsigns_status_dict ~= nil
end

return M
