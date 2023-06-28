local M = {}

local lspsaga_enable = vim.cfg.plugin__lspsaga_enable

--- wrap function for navigate lsp diagnostics, used by keymaps.
--- @param next boolean "next or prev"
--- @param severity string {"ERROR"|"WARN"|"INFO"|"HINT"}
function M.diagnostic_goto(next, severity)
  local enable_lspasaga_jump = lspsaga_enable
  local has_lspsaga = enable_lspasaga_jump and require('libs.runtime.utils').has_plugin('lspsaga.nvim')

  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  local sev = severity and vim.diagnostic.severity[severity] or nil

  if has_lspsaga then
    local saga = require('lspsaga.diagnostic')
    if next then
      saga:goto_next({ severity = sev })
    else
      saga:goto_prev({ severity = sev })
    end
    return
  end

  go({ severity = sev })
end

-- TODO: https://github.com/hrsh7th/nvim-gtd/blob/d2f34debfd8c0af3a0a81708933e33f4478fe120/lua/gtd/init.lua#L183
-- Add support for `OpenBufferInWindow` command to choose window and edit the file.
function M.goto_definition_in_file(command) require('gtd').exec({ command = command or 'edit' }) end

function M.goto_definition()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga goto_definition')
  else
    vim.lsp.buf.definition()
  end
end

function M.goto_type_definition()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga goto_type_definition')
  else
    vim.lsp.buf.definition()
  end
end

function M.goto_code_references()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga lsp_finder')
  else
    vim.lsp.buf.references()
  end
end

function M.show_signature_help()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga peek_type_definition<CR>')
  else
    vim.lsp.buf.signature_help()
  end
end

---@param pos string "line" or "cursor" or "buffer"
function M.show_diagnostics(pos)
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    if pos == 'line' then
      vim.cmd('Lspsaga show_line_diagnostics')
    elseif pos == 'cursor' then
      vim.cmd('Lspsaga show_cursor_diagnostics')
    else
      vim.cmd('Lspsaga show_buf_diagnostics')
    end
  else
    vim.diagnostic.open_float(nil, { scope = pos })
  end
end

--- Depends on ufo plugin
function M.hover_action()
  local has_ufo = require('libs.runtime.utils').has_plugin('nvim-ufo')
  local use_lspsaga = false

  local winid = nil
  if has_ufo then winid = require('ufo').peekFoldedLinesUnderCursor() end

  if not winid then
    local has_lspsaga = use_lspsaga and require('libs.runtime.utils').has_plugin('lspsaga.nvim') or false
    if has_lspsaga then
      vim.schedule(function()
        vim.cmd('Lspsaga hover_doc ++quiet')
      end)
    else
      vim.lsp.buf.hover()
    end
  end
end

function M.peek_definition()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga peek_definition')
  else
    vim.lsp.buf.definition()
  end
end

function M.peek_type_definition()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga peek_type_definition')
  else
    vim.lsp.buf.type_definition()
  end
end

function M.format_code(bufnr, opts) require('libs.lsp-format').format(bufnr, opts) end

function M.open_code_action()
  local use_lspsaga = false
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true)) end
  if use_lspsaga and has_lspsaga then
    require('lspsaga.codeaction'):code_action()
  else
    vim.lsp.buf.code_action()
  end
end

function M.open_source_action()
  local use_lspsaga = false
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true)) end
  if use_lspsaga and has_lspsaga then
    require('lspsaga.codeaction'):code_action({ context = { only = "source" } })
  else
    vim.lsp.buf.code_action({ context = { only = "source" } })
  end
end

-- rename var etc.
function M.rename_name()
  local has_lspsaga = require('libs.runtime.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    require('lspsaga.rename'):lsp_rename()
    return
  end
  vim.lsp.buf.rename()
end

-- rename file etc.
function M.ts_rename_file()
  local source = vim.api.nvim_buf_get_name(0)
  vim.ui.input({
    prompt = 'Change to: ',
    default = source,
    completion = 'file',
  }, function(input)
    if input == nil or string.match(input, '^%s*$') then
      vim.notify('Rename file canceld')
      return
    end
    local target = string.gsub(input .. '', '^%s*(.-)%s*$', '%1')
    if target == source then return end

    require('typescript').renameFile(source, target, {
      force = false,
    })
  end)
end

return M
