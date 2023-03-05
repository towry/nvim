local M = {}

-- lsp servers dict like constant used for reference.
M.servers = {
  lua = "lua_ls",
  python = "pyright",
  go = "gopls",
  rust = "rust_analyzer",
  -- for typescript and javascript.
  typescript = "tsserver",
  json = "jsonls",
  yaml = "yamlls",
  html = "html",
  css = "cssls",
  bash = "bashls",
  dockerfile = "dockerls",
  cxx = "clangd",
  java = "jdtls",
  php = "intelephense",
  ruby = "solargraph",
  scala = "metals",
  sql = "sqls",
  vim = "vimls",
  vue = "vuels",
}

return M
