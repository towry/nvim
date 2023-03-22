local M = {}

function M.setup(options)
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
    builtins.code_actions.gitsigns,
    -- require("typescript.extensions.null-ls.code-actions"), -- disabled on volar take over mode.
    -- eslint.
    builtins.code_actions.eslint,
    builtins.diagnostics.eslint,
  }

  nls.setup({
    debug = false,
    debounce = 1500,
    -- sources may not work if timeout is too short.
    default_timeout = 1500,
    save_after_format = false,
    sources = sources,
    on_attach = options.on_attach,
    update_in_insert = false,
    root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", ".git", "Makefile", ".vscode"),
  })
end

function M.has_formatter(ft)
  local sources = require("null-ls.sources")
  local available = sources.get_available(ft, "NULL_LS_FORMATTING")
  return #available > 0
end

return M;
