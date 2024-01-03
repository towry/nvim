local M = {}

---@param opts {cwd?:string}
function M.files(opts)
  opts = opts or {}

  local fzflua = require('fzf-lua')

  if not opts.cwd then
    opts.cwd = vim.t.cwd or vim.uv.cwd()
  end

  opts.ignore_current_file = true

  return fzflua.files(opts)
end

--- @see https://github.com/ibhagwan/fzf-lua/wiki/Advanced#preview-overview
---@param opts {hidden?:boolean,max_depth?:number}
function M.folders(opts)
  opts = opts or {}

  local fzflua = require('fzf-lua')
  local path = require('fzf-lua.path')

  if not opts.cwd then
    opts.cwd = vim.t.cwd or vim.uv.cwd()
  end

  -- https://github.com/ibhagwan/fzf-lua/commit/36d850b29b387768e76e59799029d1e69aee2522
  -- opts.fd_opts = string.format('--type directory  --max-depth %s', opts.max_depth or 4)
  -- opts.find_opts = [[-type d -not -path '*/\.git/*' -printf '%P\n']]
  local cmd = string.format([[fd --type directory --max-depth %s]], opts.max_depth or 4)
  local has_exa = vim.fn.executable('exa')

  opts.fzf_opts = {
    ['--preview-window'] = 'nohidden,down,50%',
    ['--preview'] = fzflua.shell.preview_action_cmd(function(items)
      return 'ls'
      -- if has_exa then
      --   return string.format('exa --color=auto --icons --group-directories-first -a %s', items[1])
      -- end
      -- return string.format('ls %s', items[1])
    end),
  }

  opts.actions = {
    ['default'] = function(selected, selected_opts)
      local first_selected = selected[1]
      if not first_selected then
        return
      end
      local entry = path.entry_to_file(first_selected, selected_opts)
      vim.print(entry)
      local entry_path = entry.path
      if not entry_path then
        return
      end
      require('userlib.mini.clue.folder-action').open(entry_path)
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
    width = 0.3,
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

return M
