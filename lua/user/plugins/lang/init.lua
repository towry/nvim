return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile', 'BufWinEnter' },
    build = function()
      if #vim.api.nvim_list_uis() == 0 then
        -- update sync if running headless
        vim.cmd.TSUpdateSync()
      else
        -- otherwise update async
        vim.cmd.TSUpdate()
      end
    end,
    dependencies = {
      'yioneko/nvim-yati',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'RRethy/nvim-treesitter-textsubjects',
      'nvim-treesitter/nvim-treesitter-refactor',
      'JoosepAlviste/nvim-ts-context-commentstring',
      -- 'kiyoon/treesitter-indent-object.nvim',
    },
    config = function()
      require_plugin_spec('lang.treesitter.rc').config()
    end,
  },

  {
    'vuki656/package-info.nvim',
    event = 'BufEnter package.json',
    ImportConfig = 'package_info',
    config = function()
      require_plugin_spec('lang.package_info.rc').config()
    end,
  },
  {
    'danymat/neogen',
    cmd = 'Neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = true,
  },

  {
    'NvChad/nvim-colorizer.lua',
    ft = vim.cfg.editorExtend__colorizer_filetypes,
    enabled = vim.cfg.editorExtend__colorizer_enable,
    opts = function()
      return require_plugin_spec('lang.opts').colorizer
    end,
  },

  {
    'm-demare/hlargs.nvim',
    event = 'BufReadPost',
    opts = function()
      return require_plugin_spec('lang.opts').hlargs
    end,
  },

  {
    'mrjones2014/lua-gf.nvim',
    ft = 'lua'
  },

  {
    'simrat39/rust-tools.nvim',
    ft = { 'rust', 'toml' },
    config = function()
      require_plugin_spec('lang.rust.rc').config()
    end,
  }
}
