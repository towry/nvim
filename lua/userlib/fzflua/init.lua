local libutils = require('userlib.runtime.utils')
local utils = require('userlib.fzflua.utils')
local M = {}

local has_fixed = function(s)
  return string.find(s, '%-%-fixed%-strings') ~= nil
end

--- @param _opts table
local function callgrep(_opts, callfn)
  local opts = vim.tbl_deep_extend('force', {}, _opts)

  opts.cwd_header = true

  if not opts.cwd then
    opts.cwd = (vim.t.CwdLocked and vim.t.Cwd) or safe_cwd()
  end

  opts.no_header = false
  opts.formatter = 'path.filename_first'
  opts.rg_opts = opts.rg_opts
    or [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --fixed-strings --]]

  opts.actions = vim.tbl_extend('keep', {
    -- press ctrl-e in fzf picker to switch to rgflow.
    ['ctrl-e'] = function()
      -- bring up rgflow ui to change rg args.
      require('rgflow').open(utils.get_last_query(), opts.rg_opts, opts.cwd, {
        custom_start = function(pattern, flags, path)
          opts.cwd = path
          opts.rg_opts = flags
          opts.query = pattern
          return callfn(opts)
        end,
      })
    end,
    ['ctrl-k'] = function()
      local new_opts = opts

      new_opts.rg_opts = libutils.toggle_cmd_option(new_opts.rg_opts, '--fixed-strings')
      new_opts.rg_opts = libutils.toggle_cmd_option(new_opts.rg_opts, '-e', true)
      new_opts.query = utils.get_last_query()

      new_opts.prompt = has_fixed(new_opts.rg_opts) and '󱙓  Live Grep (Fixed) ❯ ' or '󱙓  Live Grep❯ '

      return callfn(new_opts)
    end,
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
  }, opts.actions or {})

  return callfn(opts)
end

function M.grep(opts, is_live)
  opts = opts or {}
  if is_live == nil then
    is_live = true
  end
  local fzflua = require('fzf-lua')

  if is_live then
    opts.prompt = '󱙓  Live Grep (Fixed) ❯ '
  else
    opts.input_prompt = '󱙓  Grep❯ '
  end
  return callgrep(
    opts,
    -- schedule: fix fzf picker show and dismiss issue.
    vim.schedule_wrap(function(opts_local)
      if is_live then
        return fzflua.live_grep(opts_local)
      else
        return fzflua.grep(opts_local)
      end
    end)
  )
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
    opts.cwd = safe_cwd(vim.t.CwdLocked and vim.t.Cwd or nil)
  end

  opts.actions = {
    ['ctrl-h'] = function(_, o)
      --- toggle hidden
      opts.cmd = libutils.toggle_cmd_option(o.cmd, '--hidden')
      opts.query = utils.get_last_query()
      return fzflua.files(opts)
    end,
  }

  opts.winopts = {
    fullscreen = false,
  }
  opts.ignore_current_file = false

  return fzflua.files(opts)
end

--- @see https://github.com/ibhagwan/fzf-lua/wiki/Advanced#preview-overview
---@param opts {max_depth?:number,cwd?:string} | table
function M.folders(opts)
  opts = opts or {}

  local fzflua = require('fzf-lua')
  local path = require('fzf-lua.path')

  if not opts.cwd then
    opts.cwd = safe_cwd(vim.t.CwdLocked and vim.t.Cwd or nil)
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
  opts.toggle_ignore_flag = '--no-ignore-vcs'
  opts.winopts = {
    fullscreen = false,
    width = 0.7,
    height = 0.5,
  }
  opts.fzf_opts = {
    ['--preview-window'] = 'nohidden,down,50%',
    ['--preview'] = fzflua.shell.raw_preview_action_cmd(function(items)
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
    ['ctrl-g'] = function(_, o)
      opts.cmd = libutils.toggle_cmd_option(o.cmd, '--no-ignore-vcs')
      return fzflua.fzf_exec(opts.cmd, opts)
    end,
    ['ctrl-h'] = function(_, o)
      --- toggle hidden
      opts.cmd = libutils.toggle_cmd_option(o.cmd, '--hidden')
      opts.query = utils.get_last_query()
      return fzflua.fzf_exec(opts.cmd, opts)
    end,
  }

  return fzflua.fzf_exec(cmd, opts)
end

---@param no_buffers? boolean
function M.buffers_or_recent(no_buffers)
  local fzflua = require('fzf-lua')
  local bufopts = {
    filename_first = true,
    sort_lastused = true,
    winopts = {
      height = 0.3,
      fullscreen = false,
      preview = {
        hidden = 'hidden',
      },
    },
  }
  local oldfiles_opts = {
    prompt = ' Recent: ',
    cwd = vim.cfg.runtime__starts_cwd,
    cwd_only = true,
    include_current_session = true,
    winopts = {
      height = 0.3,
      fullscreen = false,
      preview = {
        hidden = 'hidden',
      },
    },
    keymap = {
      -- fzf = {
      --   ['tab'] = 'down',
      --   ['btab'] = 'up',
      --   ['ctrl-j'] = 'toggle+down',
      --   ['ctrl-i'] = 'down',
      -- },
    },
  }
  local buffers_actions = {}

  local oldfiles_actions = {
    actions = {
      ['ctrl-e'] = function()
        return fzflua.buffers(vim.tbl_extend('force', {
          query = utils.get_last_query(),
        }, bufopts, buffers_actions))
      end,
      ['ctrl-f'] = function()
        local query = utils.get_last_query()
        if query == '' or not query then
          vim.notify('please provide query before switch to find files mode.')
          return
        end

        M.files({
          cwd = oldfiles_opts.cwd,
          query = query,
        })
      end,
    },
  }
  buffers_actions = {
    actions = {
      ['ctrl-e'] = function()
        fzflua.oldfiles(vim.tbl_extend('force', {
          query = utils.get_last_query(),
        }, oldfiles_opts, oldfiles_actions))
      end,
    },
  }

  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  if no_buffers or count <= 1 then
    --- open recent.
    fzflua.oldfiles(vim.tbl_extend('force', {}, oldfiles_opts, oldfiles_actions))
    return
  end
  local _bo = vim.tbl_extend('force', {}, bufopts, buffers_actions)
  return require('fzf-lua').buffers(_bo)
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
            cwd = vim.t.Cwd or safe_cwd(),
            cmd = 'git branch --color',
            prompt = 'Local branches❯ ',
          })
        elseif selected[1] == 'Remote branches' then
          fzflua.git_branches({
            winopts = winopts,
            cwd = safe_cwd(vim.t.Cwd),
            cmd = 'git branch --remotes --color',
            prompt = 'Remote branches❯ ',
          })
        elseif selected[1] == 'All branches' then
          fzflua.git_branches({
            winopts = winopts,
            cwd = safe_cwd(vim.t.Cwd),
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
    winopts = {
      fullscreen = false,
    },
  })
end

--- @see https://github.com/ibhagwan/fzf-lua/wiki/Advanced#preview-overview
---@param opts {max_depth?:number,cwd?:string} | table
function M.zoxide_folders(opts)
  if vim.fn.executable('zoxide') == 0 then
    vim.notify('zoxide not installed', vim.log.levels.ERROR)
    return
  end
  local has_git_path_info = vim.fn.executable('path-git-format') == 1
  opts = opts or {}
  opts.formatter = 'path.filename_first'

  local fzflua = require('fzf-lua')
  local path = require('fzf-lua.path')

  if not opts.cwd then
    opts.cwd = safe_cwd(vim.t.CwdLocked and vim.t.Cwd or nil)
  end
  local preview_cwd = opts.cwd

  local git_branch_info_cmd = ''

  if has_git_path_info then
    git_branch_info_cmd = '| path-git-format --filter --no-bare -f"{path} [{branch}]"'
  end

  -- https://github.com/ibhagwan/fzf-lua/commit/36d850b29b387768e76e59799029d1e69aee2522
  -- opts.fd_opts = string.format('--type directory  --max-depth %s', opts.max_depth or 4)
  -- opts.find_opts = [[-type d -not -path '*/\.git/*' -printf '%P\n']]
  local cmd = string.format(
    [[zoxide query --list --exclude %s %s| awk -v home="$HOME" '{gsub("^" home, "~"); print}']],
    vim.env.HOME,
    git_branch_info_cmd
  )
  local has_exa = vim.fn.executable('eza') == 1

  opts.prompt = '󰥨  Zoxide ❯ '
  opts.cmd = cmd
  opts.cwd_header = true
  opts.cwd_prompt = true
  opts.winopts = {
    fullscreen = false,
    width = 0.7,
    height = 0.5,
  }
  opts.fzf_opts = {
    ['--tiebreak'] = 'index',
    ['--preview-window'] = 'nohidden,down,50%',
    ['--preview'] = fzflua.shell.raw_preview_action_cmd(function(items)
      local item = (items[1] or ''):gsub('%s%[.*%]$', '')

      if has_exa then
        return string.format(
          'cd %s ; eza --color=always --icons=always --group-directories-first -a %s',
          preview_cwd,
          item
        )
      end
      return string.format('cd %s ; ls %s', preview_cwd, item)
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
      entry_path = entry_path:gsub('%s%[.*%]$', '')
      print(entry_path)
      require('userlib.mini.clue.folder-action').open(entry_path)
    end,
  }

  return fzflua.fzf_exec(cmd, opts)
end

-- M.zoxide_folders()

return M

--- vim: fdl=0
