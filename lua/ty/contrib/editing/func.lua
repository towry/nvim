local M = {}

function M.show_signature_help() Ty.NOTIFY('TODO show_signature_help') end

---@param pos string "line" or "cursor"
function M.show_diagnostics(pos)
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    require('lspsaga.diagnostic').show_line_diagnostics({})
  else
    vim.diagnostic.open_float(nil, { scope = pos })
  end
end

function M.hover_action()
  local has_ufo = require('ty.core.utils').has_plugin('nvim-ufo')

  local winid = nil
  if has_ufo then winid = require('ufo').peekFoldedLinesUnderCursor() end

  if not winid then
    -- TODO: add lsp hover.
    vim.lsp.buf.hover()
  end
end

function M.peek_definition()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    require('lspsaga.provider').preview_definition()
  else
    vim.lsp.buf.definition()
  end
end

function M.format_code(bufnr) require('ty.contrib.editing.lsp.formatting').format(bufnr) end

function M.open_code_action()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  local mode = vim.api.nvim_get_mode().mode

  if mode == 'n' then
    if has_lspsaga then
      require('lspsaga.codeaction').code_action()
    else
      vim.lsp.buf_code_action()
    end
  elseif mode == 'v' then
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true))
    if has_lspsaga then
      require('lspsaga.codeaction').range_code_action()
    else
      vim.lsp.buf_range_code_action()
    end
  end
end

-- rename var etc.
function M.rename_name() vim.lsp.buf.rename() end

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
