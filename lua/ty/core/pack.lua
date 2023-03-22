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

function pack.setup(repos, initd_list)
  local data_path = vim.fn.stdpath('data')
  local config_path = vim.fn.stdpath('config')

  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  vim.opt.rtp:prepend(lazypath)
  local is_lazy_installed, lazy = pcall(require, 'lazy')
  if not is_lazy_installed then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
    })
    vim.opt.rtp:prepend(lazypath)
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
