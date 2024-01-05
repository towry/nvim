-- treesitter is not used
-- formatter and linter is configured by null-ls
return {
  ['css'] = {
    patterns = { '*.css', },
    lspconfig = { 'cssls', 'null-ls' },
  },
  ['scss>css'] = {
    filetypes = { 'scss', 'css' },
    patterns = { '*.css', '*.scss' },
  },
  ['html'] = {
    lspconfig = { 'html', 'null-ls' },
  },
  ['json'] = {
    patterns = { '*.json', '*.jsonc' },
    lspconfig = { 'jsonls' },
    treesitter = { 'json', 'jsonc' },
  },
  ['vue'] = {
    filetypes = vim.cfg.lsp__server_volar_takeover_mode
        and { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
        or { 'vue' },
    lspconfig = { 'volar' },
    treesitter = { 'vue' }
  },
  ['typescript'] = {
    filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    patterns = { '*.ts', '*.tsx', '*.js', '*.jsx' },
    lspconfig = { 'tsserver', 'eslint', 'null-ls' },
    treesitter = { 'typescript', 'javascript', 'tsx' },
  },
  ['lua'] = {
    lspconfig = { 'lua_ls', 'null-ls' },
    -- formatter = 'stylua',
    linter = 'luacheck',
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
  },
  -- ['go'] = {
  --   patterns = { '*.go', 'go.mod' },
  --   lspconfig = 'gopls',
  --   formatter = 'gofmt',
  -- },
  ['markdown'] = {
    patterns = { '*.md', '*.markdown' },
    lspconfig = { 'marksman', 'null-ls' },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    linter = 'shellcheck',
    formatter = 'shfmt',
    treesitter = { 'bash' },
  },
  -- ['nix'] = {
  --   lspconfig = 'nil_ls',
  --   linter = 'statix',
  --   formatter = 'nixfmt',
  -- },
  ['toml'] = {
    lspconfig = { 'taplo', }
  },
  ['fish'] = {
    formatter = 'fish_indent',
    linter = 'fish',
  },
  ['yaml'] = {
    lspconfig = { 'yamlls', },
    treesitter = { 'yaml' },
  },
}
