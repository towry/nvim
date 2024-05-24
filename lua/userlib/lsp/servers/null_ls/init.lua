local M = {}

local setup_done = false

--- TODO: add buffer check.
local function inject_nls_methods(nls)
  local client = require('null-ls.client')
  local rpc = require('null-ls.rpc')

  local original_flush = rpc.flush
  rpc.flush = function(...)
    if vim.b.lsp_disable then
      return
    end
    original_flush(...)
  end

  local original_try_add = client.try_add
  client.try_add = function(...)
    if vim.b.lsp_disable or vim.bo.buftype ~= '' then
      return
    end
    original_try_add(...)
  end
end

M.setup = function()
  if setup_done then
    return
  end

  local present, nls = pcall(require, 'null-ls')
  if not present then
    Ty.NOTIFY('null-ls is not installed')
    return
  end

  inject_nls_methods()

  -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
  local builtins = nls.builtins

  -- use `filetypes` to specific which filetypes to run the generators.
  local sources = {
    builtins.formatting.stylua.with({
      filetypes = { 'lua', 'luau' },
    }),
    -- only prettier works with monorepo.
    builtins.formatting.prettier,
    builtins.formatting.stylua,
    -- builtins.code_actions.gitsigns,
    -- require("typescript.extensions.null-ls.code-actions"), -- disabled on volar take over mode.
    -- eslint.
    require('none-ls.diagnostics.eslint'),
    require('none-ls.code_actions.eslint'),
    -- Make sure do not use the version of mason.
    -- yaml
    builtins.diagnostics.yamllint,
  }

  nls.setup({
    debug = false,
    debounce = 1500,
    -- sources may not work if timeout is too short.
    default_timeout = 1500,
    save_after_format = false,
    sources = sources,
    update_in_insert = false,
    -- root_dir = function()
    --   return require('userlib.runtime.utils').get_root()
    -- end
    root_dir = require('null-ls.utils').root_pattern(unpack(require('userlib.runtime.utils').root_patterns)),
  })
end

--- @param bufnr number
--- @param ft? string
--- @return string[]
M.get_active_sources = function(bufnr, ft)
  local sources = require('null-ls.sources')
  local filetype = ft or vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  local list = {}
  local added = {}

  for _, source in ipairs(sources.get_available(filetype)) do
    if not added[source.name] then
      table.insert(list, source.name)
      added[source.name] = true
    end
  end

  return list
end

return M
