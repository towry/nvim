-- treesitter is not used
-- formatter and linter is configured by null-ls
-- use vim.filettype.add to manage pattern and filetype.

return {
  ['css'] = {
    lspconfig = { 'cssls', 'null-ls' },
  },
  ['scss>css'] = {
    filetypes = { 'scss', 'css' },
  },
  ['html'] = {
    lspconfig = { 'html', 'null-ls' },
  },
  ['json'] = {
    lspconfig = { 'jsonls' },
    treesitter = { 'json', 'jsonc' },
  },
  ['vue'] = {
    filetypes = vim.cfg.lsp__server_volar_takeover_mode
        and { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      or { 'vue' },
    lspconfig = { 'volar', 'null-ls', 'eslint' },
  },
  ['typescript'] = {
    filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    lspconfig = { 'typescript-tools', 'eslint', 'null-ls' },
    treesitter = { 'typescript', 'javascript', 'tsx' },
  },
  ['lua'] = {
    lspconfig = { 'lua_ls', 'null-ls' },
    linter = 'luacheck',
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    -- lspconfig = 'rust_analyzer',
  },
  -- ['go'] = {
  --   lspconfig = 'gopls',
  -- },
  ['markdown'] = {
    lspconfig = { 'marksman', 'null-ls' },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    linter = 'shellcheck',
    treesitter = { 'bash' },
  },
  -- ['nix'] = {
  --   lspconfig = 'nil_ls',
  -- },
  ['toml'] = {
    lspconfig = { 'taplo' },
  },
  ['fish'] = {
    linter = 'fish',
  },
  ['yaml'] = {
    lspconfig = { 'yamlls' },
    treesitter = { 'yaml' },
  },
}
