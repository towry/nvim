return {
  ['css'] = {
    patterns = { '*.css', '*.scss' },
    lspconfig = { 'cssls' },
  },
  ['html'] = {
    lspconfig = { 'html' },
  },
  ['json'] = {
    patterns = { '*.json', '*.jsonc' },
    lspconfig = 'jsonls',
    treesitter = { 'json', 'jsonc' },
  },
  ['typescript'] = {
    patterns = { '*.ts', '*.tsx', '*.js', '*.jsx' },
    lspconfig = { 'tsserver', 'eslint' },
    formatter = 'prettier_d',
    treesitter = { 'typescript', 'javascript', 'tsx' },
  },
  ['lua'] = {
    lspconfig = 'lua_ls',
    formatter = 'stylua',
    linter = 'luacheck',
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
  },
  ['go'] = {
    patterns = { '*.go', 'go.mod' },
    lspconfig = 'gopls',
    formatter = 'gofmt',
  },
  ['markdown'] = {
    patterns = { '*.md', '*.markdown' },
    lspconfig = 'marksman',
    formatter = {
      'prettier_d',
      'cbfmt',
    },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    linter = 'shellcheck',
    formatter = 'shfmt',
    treesitter = { 'bash' },
  },
  ['swift'] = {
    lspconfig = 'sourcekit',
    treesitter = false, -- requires treesitter-cli and only really works on mac
  },
  ['nix'] = {
    lspconfig = 'nil_ls',
    linter = 'statix',
    formatter = 'nixfmt',
  },
  ['toml'] = {
    lspconfig = 'taplo',
  },
  ['fish'] = {
    formatter = 'fish_indent',
    linter = 'fish',
  },
  ['yaml'] = {
    lspconfig = 'yamlls',
    treesitter = { 'yaml' },
  },
}