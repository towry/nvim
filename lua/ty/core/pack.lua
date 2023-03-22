local uv, api = vim.loop, vim.api

local pack = {
  repos = {},
  initd = {},
}

local lazy_opts = {
  dev = {
    path = '~/workspace/git-repos',
    fallback = true,
  },
  concurrency = 5,
  install = { colorscheme = { Ty.Config.ui.theme.colorscheme } },
  checker = { enabled = false },
  defaults = { lazy = true },
  change_detection = {
    enabled = false,
  },
  git = {
    timeout = 120,
    url_format = 'https://ghproxy.com/https://github.com/%s',
  },
  ui = {
    icons = {
      lazy = ' ',
      plugin = ' ',
    },
  },
  custom_keys = {
    -- open lazygit log
    ['<localleader>l'] = function(plugin)
      require('lazy.util').float_term({ 'lazygit', 'log' }, {
        cwd = plugin.dir,
      })
    end,
    -- open a terminal for the plugin dir
    ['<localleader>t'] = function(plugin)
      require('lazy.util').float_term(nil, {
        cwd = plugin.dir,
      })
    end,
  },
  readme = {
    enabled = false,
  },
  performance = {
    reset_packpath = true,
    cache = {
      enabled = false,
    },
    rtp = {
      -- https://github.com/neovim/neovim/tree/master/runtime/plugin
      disabled_plugins = {
        'gzip',
        'man',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        -- for downloading spell files.
        'spellfile_plugin',
      },
    },
  },
}

local function path_join(...) return table.concat(vim.tbl_flatten({ ... }), '/') end

function pack.setup(repos, initd_list)
  local data_path = vim.fn.stdpath('data')
  local config_path = vim.fn.stdpath('config')

  local lazy_path = path_join(data_path, 'lazy', 'lazy.nvim')
  vim.opt.runtimepath:prepend(lazy_path)
  local lazy_ok, lazy = pcall(require, 'lazy')
  if not lazy_ok then
    local cmd = '!git clone https://github.com/folke/lazy.nvim ' .. lazy_path
    api.nvim_command(cmd)
    lazy = require('lazy')
  end

  vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('init_after_lazy_done', { clear = true }),
    pattern = 'LazyDone',
    callback = function()
      for _, init in ipairs(initd_list) do
        init()
      end
    end,
  })
  lazy.setup(repos, lazy_opts)
end

return pack
