-- treesitter is not used
-- formatter and linter is configured by null-ls
-- use vim.filettype.add to manage pattern and filetype.

--- TODO: add root_patterns
return {
  ['nim'] = {
    lspconfig = { 'nim_langserver' },
  },
  ['python'] = {
    lspconfig = { 'pyright', 'ruff' },
  },
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
    lspconfig = { 'jsonls', 'null-ls' },
    treesitter = { 'json', 'jsonc' },
  },
  ['vue'] = {
    filetypes = vim.cfg.lsp__server_volar_takeover_mode
        and { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      or { 'vue' },
    lspconfig = { 'volar', 'null-ls', 'vtsls', 'tailwindcss' },
  },
  ['typescript'] = {
    filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    lspconfig = { 'vtsls', 'null-ls', 'tailwindcss' },
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
  ['nix'] = {
    lspconfig = { 'nil_ls' },
  },
  ['zig'] = {
    lspconfig = { 'zls' },
    root_patterns = { 'zls.json', 'build.zig', '.git' },
  },
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
  ['cpp'] = {
    lspconfig = { 'clangd' },
    filetypes = { 'c', 'cpp' },
  },
}
