return function()
  local present, nls = pcall(require, "null-ls")
  if not present then
    Ty.NOTIFY("null-ls is not installed")
    return
  end
  local builtins = nls.builtins

  -- use `filetypes` to specific which filetypes to run the generators.
  local sources = {
    -- builtins.formatting.stylua.with({
    -- 	filetypes = { "lua" }
    -- }),
    -- builtins.formatting.prettier,
    builtins.formatting.prettierd,
    -- builtins.code_actions.gitsigns,
    -- require("typescript.extensions.null-ls.code-actions"), -- disabled on volar take over mode.
    -- eslint.
    builtins.code_actions.eslint_d,
    builtins.diagnostics.eslint_d,
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
    --   return require('libs.runtime.utils').get_root()
    -- end
    root_dir = require("null-ls.utils").root_pattern(unpack(require('libs.runtime.utils').root_patterns)),
  })
end
