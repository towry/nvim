local M = {}

-- ms
M.interval = 4 * 1000
M.ticks = 0
---@type vim.uv.Timer?
M.timer = nil
M.loading = false

M.gitinfo = {
  conflicted = 0,
  deleted = 0,
  renamed = 0,
  modified = 0,
  untracked = 0,
  typechanged = 0,
  unstaged = 0,
  staged = 0,
  aheads = 0,
  behinds = 0,
  dirty = 0,
}
local gitinfo = M.gitinfo

--- debug
_G.gitinfo = function()
  vim.print(M.gitinfo)
end

local gitstatus = {
  is_deleted = function(line)
    return line:find('D')
  end,
  is_modified = function(line)
    --- line should ends with 'M' or ends with 'A'
    return line:find('M$') or line:find('A$')
  end,
  is_staged = function(line)
    --- line should starts with 'M' or starts with 'A' or starts with T
    return line:find('^M') or line:find('^A') or line:find('^T')
  end,
  is_typechanged = function(line)
    return line:find('T$')
  end,
  is_untracked = function(line)
    return line:find('^%s*%?%?')
  end,
  is_renamed = function(line)
    return line:find('R')
  end,
  is_conflicted = function(line)
    -- DD unmerged, both deleted.
    -- AA unmerged, both added.
    return line:find('U') or line:find('DD') or line:find('AA')
  end,
}

--- @param short_status string first characters that until a space of git status output line.
local function update_gitinfo(short_status, o)
  if gitstatus.is_conflicted(short_status) then
    o.conflicted = o.conflicted + 1
  elseif gitstatus.is_deleted(short_status) then
    o.deleted = o.deleted + 1
  elseif gitstatus.is_renamed(short_status) then
    o.renamed = o.renamed + 1
  elseif gitstatus.is_modified(short_status) then
    o.modified = o.modified + 1
  elseif gitstatus.is_untracked(short_status) then
    o.untracked = o.untracked + 1
  elseif gitstatus.is_typechanged(short_status) then
    o.typechanged = o.typechanged + 1
  elseif gitstatus.is_staged(short_status) then
    o.staged = o.staged + 1
  end
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
    '--verbose',
  }

  local on_exit = function(obj)
    M.loading = false
    if obj.code ~= 0 then
      vim.schedule(function()
        vim.notify('gitinfo failed', vim.log.levels.ERROR)
      end)
      -- failed
      return
    end

    local output = obj.stdout
    --- output is string
    if type(output) == 'string' then
      output = vim.split(output, '\n')
    end

    local o = {
      conflicted = 0,
      deleted = 0,
      renamed = 0,
      modified = 0,
      untracked = 0,
      typechanged = 0,
      unstaged = 0,
      staged = 0,
      dirty = 0,
      aheads = 0,
      behinds = 0,
    }

    for _, line in ipairs(output) do
      -- take first characters that until a space.
      -- can starts with a space.
      local short_status = string.match(line, "^%s*[^%s]+")
      if short_status and short_status:find('##') then
        local ahead = line:match('%[ahead%s+(%d+)%]')
        local behind = line:match('%[behind%s+(%d+)%]')
        if ahead then
          o.aheads = tonumber(ahead)
        end
        if behind then
          o.behinds = tonumber(behind)
        end
      elseif short_status ~= nil then
        o.dirty = o.dirty + 1
      end
    end

    -- o.unstaged = o.modified
    -- o.staged = o.staged + o.renamed

    -- gitinfo.staged = o.staged
    -- gitinfo.unstaged = o.unstaged
    -- gitinfo.modified = o.modified
    -- gitinfo.deleted = o.deleted
    -- gitinfo.renamed = o.renamed
    -- gitinfo.untracked = o.untracked
    -- gitinfo.typechanged = o.typechanged
    -- gitinfo.conflicted = o.conflicted
    gitinfo.dirty = o.dirty
    gitinfo.aheads = o.aheads
    gitinfo.behinds = o.behinds
  end

  vim.system(cmd, {}, on_exit)
end

function M.start()
  if M.timer or vim.g.vscode then
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
