local M = {}

function M.show_signature_help()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga peek_type_definition<CR>')
  else
    vim.lsp.buf.signature_help()
  end
end

---@param pos string "line" or "cursor" or "buffer"
function M.show_diagnostics(pos)
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    require('lspsaga.diagnostic'):show_diagnostics({}, pos)
  else
    vim.diagnostic.open_float(nil, { scope = pos })
  end
end

function M.hover_action()
  local has_ufo = require('ty.core.utils').has_plugin('nvim-ufo')

  local winid = nil
  if has_ufo then winid = require('ufo').peekFoldedLinesUnderCursor() end

  if not winid then
    local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
    if has_lspsaga then
      vim.schedule(function()
        vim.cmd('Lspsaga hover_doc')
      end)
    else
      vim.lsp.buf.hover()
    end
  end
end

function M.peek_definition()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga peek_definition')
  else
    vim.lsp.buf.definition()
  end
end

function M.peek_type_definition()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga peek_type_definition')
  else
    vim.lsp.buf.type_definition()
  end
end

function M.format_code(bufnr) require('ty.contrib.editing.lsp.formatting').format(bufnr) end

function M.open_code_action()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true)) end
  if has_lspsaga then
    require('lspsaga.codeaction'):code_action()
  else
    vim.lsp.buf.code_action()
  end
end

-- rename var etc.
function M.rename_name()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
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
