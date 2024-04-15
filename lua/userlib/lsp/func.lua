local utils = require('userlib.runtime.utils')
local M = {}

local function get_diagnostic_at_cursor()
  local cur_buf = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local entrys = vim.diagnostic.get(cur_buf, { lnum = line - 1 })
  local res = {}
  for _, v in pairs(entrys) do
    if v.col <= col and v.end_col >= col then
      table.insert(res, {
        code = v.code,
        message = v.message,
        range = {
          ['start'] = {
            character = v.col,
            line = v.lnum,
          },
          ['end'] = {
            character = v.end_col,
            line = v.end_lnum,
          },
        },
        severity = v.severity,
        source = v.source or nil,
      })
    end
  end
  return res
end

--- wrap function for navigate lsp diagnostics, used by keymaps.
--- @param next boolean "next or prev"
--- @param severity string {"ERROR"|"WARN"|"INFO"|"HINT"}
function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  local sev = severity and vim.diagnostic.severity[severity] or nil

  go({ severity = sev })
end

-- gtd have bad perf.
-- TODO: https://github.com/hrsh7th/nvim-gtd/blob/d2f34debfd8c0af3a0a81708933e33f4478fe120/lua/gtd/init.lua#L183
-- Add support for `OpenBufferInWindow` command to choose window and edit the file.
function M.goto_definition_in_file(command)
  vim.lsp.buf.definition()
  -- require('gtd').exec({ command = command or 'edit' })
end

function M.goto_declaration()
  utils.use_plugin('fzf-lua', function(fzf)
    fzf.lsp_declarations({
      fullscreen = false,
    })
  end)
end

function M.lsp_workspace_symbol(initial_query)
  utils.use_plugin('fzf-lua', function(fzf)
    -- <c-g> to toggle live query
    fzf.lsp_live_workspace_symbols({
      query = initial_query,
      fullscreen = false,
      no_autoclose = true,
      cwd_only = true,
    })
  end)
end

function M.goto_definition()
  -- vim.lsp.buf.definition()
  require('userlib.telescope.lsp').lsp_references()
end

function M.goto_type_definition()
  vim.lsp.buf.definition()
end

function M.goto_code_references()
  require('userlib.telescope.lsp').lsp_references()
end

function M.show_signature_help()
  vim.lsp.buf.signature_help()
end

---@param pos string "line" or "cursor" or "buffer"
function M.show_diagnostics(pos)
  vim.diagnostic.open_float(nil, { scope = pos })
end

--- Depends on ufo plugin
function M.hover_action()
  local has_ufo = require('userlib.runtime.utils').has_plugin('nvim-ufo')

  local winid = nil
  if has_ufo then
    winid = require('ufo').peekFoldedLinesUnderCursor()
  end

  if not winid then
    vim.lsp.buf.hover()
  end
end

function M.peek_definition()
  utils.use_plugin('fzf-lua', function(fzf)
    fzf.lsp_definitions({
      fullscreen = false,
    })
  end, function()
    vim.lsp.buf.definition()
  end)
end

function M.peek_type_definition()
  utils.use_plugin('fzf-lua', function(fzf)
    fzf.lsp_typedefs({
      fullscreen = false,
    })
  end, function()
    vim.lsp.buf.type_definition()
  end)
end

-- function M.format_code(bufnr) require('userlib.lsp.fmt').format_document(bufnr) end
function M.format_code(bufnr, opts)
  require('userlib.lsp.servers.null_ls.fmt').format(bufnr, opts)
end

function M.open_code_action()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true))
  else
    require('userlib.lsp.func').jump_to_diagnostic_in_line()
  end
  if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
    require('fzf-lua').lsp_code_actions({
      winopts = {
        fullscreen = false,
        height = 0.8,
        width = 0.5,
        preview = {
          hidden = 'hidden',
          layout = 'vertical',
          vertical = 'down:30%',
        },
      },
    })
    return
  end
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_codeAction
  vim.lsp.buf.code_action({
    context = {
      -- only = {
      --   'source',
      -- },
      diagnostics = get_diagnostic_at_cursor(),
    },
  })
end

function M.jump_to_diagnostic_in_line()
  local current_line_cursor = vim.api.nvim_win_get_cursor(0)
  local next_dia_pos = vim.diagnostic.get_next_pos({
    float = false,
  })
  -- + 1 is because the data is 0-indexed
  if next_dia_pos and (next_dia_pos[1] + 1) == current_line_cursor[1] then
    -- move cursor to next_dia_pos
    vim.api.nvim_win_set_cursor(0, { next_dia_pos[1] + 1, next_dia_pos[2] })
    return true
  end

  local prev_dia_pos = vim.diagnostic.get_prev_pos({
    float = false,
  })
  if prev_dia_pos and (prev_dia_pos[1] + 1) == current_line_cursor[1] then
    -- move cursor to prev_dia_pos
    vim.api.nvim_win_set_cursor(0, { prev_dia_pos[1] + 1, prev_dia_pos[2] })
    return true
  end
  return false
end

function M.open_source_action()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' then
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, false, true))
  end
  vim.lsp.buf.code_action({ context = { only = 'source' } })
end

-- rename var etc.
function M.rename_name()
  vim.lsp.buf.rename()
end

return M
