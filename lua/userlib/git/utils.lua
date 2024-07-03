local utils = require('userlib.runtime.utils')
local M = {}

--- Get git branch name.
M.get_git_abbr_head = function()
  local res = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]
  if vim.startswith(res, 'fatal:') then
    return nil
  else
    return res
  end
end

M.toggle_files_history = function(range, args)
  local lib = require('diffview.lib')
  local diffview = require('diffview')

  vim.schedule(function()
    local view = lib.get_current_view()
    if view == nil then
      diffview.file_history(range, args)
      return
    end

    if view then
      view:close()
      lib.dispose_view(view)
    end
  end)
end

---@returns {diffview?:boolean}
local get_current_vcs_view_providers = function()
  return require('userlib.runtime.buffer').reduce_bufnrs(function(carry, bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if string.find(name, 'diffview://') ~= nil then
      carry['diffview'] = {
        bufnr = bufnr,
      }
    elseif string.find(name, 'fugitive://') ~= nil then
      carry['fugitive'] = {
        bufnr = bufnr,
      }
    elseif string.find(name, 'gitsigns://') ~= nil then
      carry['gitsigns'] = {
        bufnr = bufnr,
      }
    end
    --
    return carry
  end, {})
end

local close_win = function(bufnr)
  local win = require('userlib.runtime.buffer').get_buf_win(bufnr)
  if win then
    vim.api.nvim_win_close(win, false)
  end
end

--- Close git views according the providers.
--- TODO: if more than one providers, let use choose which to close.
M.close_git_views = function()
  vim.schedule(function()
    local providers = get_current_vcs_view_providers()
    if providers.diffview == true then
      vim.cmd('DiffviewClose')
    elseif providers.fugitive or providers.gitsigns then
      local bufnr = (providers.fugitive and providers.fugitive.bufnr)
        or (providers.gitsigns and providers.gitsigns.bufnr)
      if bufnr then
        close_win(bufnr)
      end
    end
  end)
end

M.toggle_working_changes = function()
  local lib = require('diffview.lib')
  local diffview = require('diffview')

  vim.schedule(function()
    local view = lib.get_current_view()
    if view == nil then
      diffview.open()
      return
    end

    if view then
      view:close()
      lib.dispose_view(view)
    end
  end)
end

local function process_abbrev_head(gitdir, head_str, path)
  if not gitdir then
    return head_str
  end

  if head_str == 'HEAD' then
    return vim.fn.trim(M.run_git_cmd('cd ' .. path .. ' && git --no-pager rev-parse --short HEAD'))
  end

  return head_str
end

function M.run_git_cmd(cmd)
  local cmd_result = vim.fn.system(cmd)
  if cmd_result == nil or utils.starts_with(cmd_result, 'fatal:') then
    return nil
  end

  return cmd_result
end

function M.get_git_repo()
  local gsd = vim.b.gitsigns_status_dict
  if gsd and gsd.root and #gsd.root > 0 then
    return gsd.root
  end

  local git_root, _ = M.get_repo_info()
  return git_root
end

function M.get_current_branch_name()
  local gsd = vim.b.gitsigns_status_dict
  if gsd and gsd.head and #gsd.head > 0 then
    return gsd.head
  end

  local _, abbrev_head = M.get_repo_info()
  return abbrev_head
end

function M.get_repo_info()
  local cwd = vim.fn.expand('%:p:h')
  local data = vim.fn.trim(
    M.run_git_cmd('cd ' .. cwd .. ' && git --no-pager rev-parse --show-toplevel --absolute-git-dir --abbrev-ref HEAD')
  )
  local results = utils.split(data, '\n')

  local git_root = results[1]
  local abbrev_head = process_abbrev_head(results[2], results[3], cwd)

  return git_root, abbrev_head
end

function M.is_head_wip_commit()
  local res = vim
    .system({
      'git',
      'log',
      '--format=%B',
      '-n',
      '1',
      'HEAD',
    }, { text = true })
    :wait()
  if res.code == 0 then
    -- local text = '[WIP]: kdjkkfj'
    local text = res.stdout or ''
    if text:find('%[WIP%]:') then
      return true
    end
  end

  return false
end

return M
