local libutils = require('userlib.runtime.utils')
local M = {}

--- @param opts table
local function callgrep(opts, callfn)
  opts = opts or {}

  opts.cwd_header = true

  if not opts.cwd then
    opts.cwd = vim.t.cwd or vim.uv.cwd()
  end

  opts.no_header = false
  opts.fullscreen = true
  opts.rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]]

  opts.actions = {
    ['ctrl-h'] = function()
      --- toggle hidden files search.
      opts.rg_opts = libutils.toggle_cmd_option(opts.rg_opts, '--hidden')
      return callfn(opts)
    end,
    ['ctrl-a'] = function()
      --- toggle rg_glob
      opts.rg_glob = not opts.rg_glob
      if opts.rg_glob then
        opts.prompt = opts.prompt .. '(G): '
      else
        -- remove (G): from prompt
        opts.prompt = string.gsub(opts.prompt, '%(G%): ', '')
      end
      -- usage: {search_query} --{glob pattern}
      -- hello --*.md *.js
      return callfn(opts)
    end,
  }

  return callfn(opts)
end

function M.grep(opts, is_live)
  opts = opts or {}
  if is_live == nil then
    is_live = true
  end
  local fzflua = require('fzf-lua')
  if is_live then
    opts.prompt = '󰥨  Live Grep❯ '
  else
    opts.input_prompt = '󰥨  Grep❯ '
  end
  return callgrep(opts, function(opts_local)
    if is_live then
      return fzflua.live_grep(opts_local)
    else
      return fzflua.grep(opts_local)
    end
  end)
end

function M.grep_visual(opts)
  local fzflua = require('fzf-lua')
  return callgrep(opts, function(opts_local)
    return fzflua.grep_visual(opts_local)
  end)
end

---@param opts {cwd?:string} | table
function M.files(opts)
  opts = opts or {}

  local fzflua = require('fzf-lua')

  if not opts.cwd then
    opts.cwd = vim.t.cwd or vim.uv.cwd()
  end

  opts.fullscreen = true
  opts.ignore_current_file = true

  return fzflua.files(opts)
end

--- @see https://github.com/ibhagwan/fzf-lua/wiki/Advanced#preview-overview
---@param opts {max_depth?:number,cwd?:string} | table
function M.folders(opts)
  opts = opts or {}

  local actions = require('fzf-lua.actions')
  local fzflua = require('fzf-lua')
  local path = require('fzf-lua.path')

  if not opts.cwd then
    opts.cwd = vim.t.cwd or vim.uv.cwd()
  end
  local preview_cwd = opts.cwd

  -- https://github.com/ibhagwan/fzf-lua/commit/36d850b29b387768e76e59799029d1e69aee2522
  -- opts.fd_opts = string.format('--type directory  --max-depth %s', opts.max_depth or 4)
  -- opts.find_opts = [[-type d -not -path '*/\.git/*' -printf '%P\n']]
  local cmd = string.format([[fd --color always --type directory --max-depth %s]], opts.max_depth or 4)
  local has_exa = vim.fn.executable('eza') == 1

  opts.prompt = '󰥨  Folders❯ '
  opts.cmd = cmd
  opts.cwd_header = true
  opts.cwd_prompt = true
  opts.toggle_ignore_flag = '--no-ignore'
  opts.fullscreen = true
  opts.fzf_opts = {
    ['--preview-window'] = 'nohidden,down,50%',
    ['--preview'] = fzflua.shell.preview_action_cmd(function(items)
      if has_exa then
        return string.format(
          'cd %s ; eza --color=always --icons=always --group-directories-first -a %s',
          preview_cwd,
          items[1]
        )
      end
      return string.format('cd %s ; ls %s', preview_cwd, items[1])
    end),
  }

  opts.actions = {
    ['default'] = function(selected, selected_opts)
      local first_selected = selected[1]
      if not first_selected then
        return
      end
      local entry = path.entry_to_file(first_selected, selected_opts)
      local entry_path = entry.path
      if not entry_path then
        return
      end
      require('userlib.mini.clue.folder-action').open(entry_path)
    end,
    ['ctrl-g'] = function()
      opts.__ACT_TO = function(o)
        opts = vim.tbl_extend('force', opts, o)
        return fzflua.fzf_exec(opts.cmd, opts)
      end
      actions.toggle_ignore(nil, opts)
    end,
    ['ctrl-h'] = function()
      --- toggle hidden
      opts.cmd = libutils.toggle_cmd_option(opts.cmd, '--hidden')
      return fzflua.fzf_exec(opts.cmd, opts)
    end,
  }

  return fzflua.fzf_exec(cmd, opts)
end

function M.buffers_or_recent()
  local fzflua = require('fzf-lua')

  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  if count <= 1 then
    --- open recent.
    fzflua.oldfiles({
      cwd = vim.cfg.runtime__starts_cwd,
      cwd_only = true,
      winopts = {
        fullscreen = false,
      },
    })
    return
  end
  return fzflua.buffers({
    winopts = {
      fullscreen = false,
    },
  })
end

function M.git_branches()
  local fzflua = require('fzf-lua')
  local winopts = {
    fullscreen = false,
    width = 0.8,
    height = 0.4,
  }

  fzflua.fzf_exec({
    'Local branches',
    'Remote branches',
    'All branches',
  }, {
    actions = {
      ['default'] = function(selected)
        if not selected or #selected <= 0 then
          return
        end
        if selected[1] == 'Local branches' then
          fzflua.git_branches({
            winopts = winopts,
            cwd = vim.t.cwd or vim.uv.cwd(),
            cmd = 'git branch --color',
            prompt = 'Local branches❯ ',
          })
        elseif selected[1] == 'Remote branches' then
          fzflua.git_branches({
            winopts = winopts,
            cwd = vim.t.cwd or vim.uv.cwd(),
            cmd = 'git branch --remotes --color',
            prompt = 'Remote branches❯ ',
          })
        elseif selected[1] == 'All branches' then
          fzflua.git_branches({
            winopts = winopts,
            cwd = vim.t.cwd or vim.uv.cwd(),
            cmd = 'git branch --all --color',
            prompt = 'All branches❯ ',
          })
        end
      end,
    },
    winopts = winopts,
  })
end

function M.command_history()
  local fzflua = require('fzf-lua')

  fzflua.command_history({
    fullscreen = false,
  })
end

return M
