local M = {}

--- wrap function for navigate lsp diagnostics, used by keymaps.
--- @param next boolean "next or prev"
--- @param severity string {"ERROR"|"WARN"|"INFO"|"HINT"}
function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  local sev = severity and vim.diagnostic.severity[severity] or nil

  go({ severity = sev })
end

-- TODO: https://github.com/hrsh7th/nvim-gtd/blob/d2f34debfd8c0af3a0a81708933e33f4478fe120/lua/gtd/init.lua#L183
-- Add support for `OpenBufferInWindow` command to choose window and edit the file.
function M.goto_definition_in_file(command) require('gtd').exec({ command = command or 'edit' }) end

function M.goto_definition()
  -- vim.lsp.buf.definition()
  require('userlib.telescope.lsp').lsp_references()
end

function M.goto_type_definition() vim.lsp.buf.definition() end

function M.goto_code_references() require('userlib.telescope.lsp').lsp_references() end

function M.show_signature_help() vim.lsp.buf.signature_help() end

---@param pos string "line" or "cursor" or "buffer"
function M.show_diagnostics(pos) vim.diagnostic.open_float(nil, { scope = pos }) end

--- Depends on ufo plugin
function M.hover_action()
  local has_ufo = require('userlib.runtime.utils').has_plugin('nvim-ufo')

  local winid = nil
  if has_ufo then winid = require('ufo').peekFoldedLinesUnderCursor() end

  if not winid then vim.lsp.buf.hover() end
end

function M.peek_definition() vim.lsp.buf.definition() end

function M.peek_type_definition() vim.lsp.buf.type_definition() end

function M.format_code(bufnr) require('userlib.lsp.fmt').format_document(bufnr) end

function M.open_code_action()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true)) end
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_codeAction
  vim.lsp.buf.code_action({
    context = {
      only = {
        'source',
      },
      triggerKind = 1,
      diagnostics = {},
    },
  })
end

function M.open_source_action()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true)) end
  vim.lsp.buf.code_action({ context = { only = 'source' } })
end

-- rename var etc.
function M.rename_name() vim.lsp.buf.rename() end

return M
