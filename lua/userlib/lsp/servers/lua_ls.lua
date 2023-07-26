local M = {}

M.settings = {
  completion = {
    callSnippet = 'Replace',
  },
  Lua = {
    diagnostics = {
      globals = { 'vim', 'bit', 'Ty' },
    },
    hint = {
      enable = true,
    }
  },
}

return function(opts)
  if require('userlib.runtime.utils').has_plugin('neodev.nvim') then
    require('neodev').setup({
      setup_jsonls = false,
      lspconfig = false,
      library = {
        plugins = { 'nvim-treesitter', 'plenary.nvim', 'telescope.nvim', 'nvim-luadev' },
      },
    })
  end

  require('lspconfig').lua_ls.setup(vim.tbl_extend('force', opts, M))
end
