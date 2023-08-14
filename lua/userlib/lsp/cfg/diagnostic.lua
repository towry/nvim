local utils = require('userlib.runtime.utils')
local M = {}

local original_underline_function_show = vim.diagnostic.handlers.underline.show
local original_virtual_text_function_show = vim.diagnostic.handlers.virtual_text.show

local DiagSourceToIcon = {
  ['Lua Diagnostics'] = 'icon.lua',
  ['ts'] = 'icon.ts',
}
local DiagSourceNameFormatMap = {
  ['Lua Diagnostics'] = 'lua_ls',
  ['ts'] = 'ts',
}
local DiagSourceToIconCache = {}

local devicon = nil

---@param source_name string
local function get_icon_for_diag_source(source_name)
  local fname = DiagSourceToIcon[source_name]
  if not fname then
    return source_name
  end
  if DiagSourceToIconCache[source_name] then
    return DiagSourceToIconCache[source_name]
  end
  if not devicon then
    if utils.has_plugin('nvim-web-devicons') then
      devicon = require('nvim-web-devicons')
    else
      return source_name
    end
  end
  DiagSourceToIconCache[source_name] = devicon.get_icon(DiagSourceToIcon[source_name])
  return DiagSourceToIconCache[source_name]
end

local function get_formal_source_name(source_name)
  local format = DiagSourceNameFormatMap[source_name]
  if not format then
    return source_name
  end
  return format
end

M.remove_multiline_underline_handler = function(namespace, bufnr, diagnostics, opts)
  local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local diagnostics_without_multiline = vim.tbl_map(function(diagnostic)
    diagnostic.end_col = diagnostic.lnum == diagnostic.end_lnum and diagnostic.end_col
        or #buf_lines[diagnostic.lnum + 1]
    diagnostic.end_lnum = diagnostic.lnum

    return diagnostic
  end, vim.deepcopy(diagnostics))

  original_underline_function_show(namespace, bufnr, diagnostics_without_multiline, opts)
end

M.add_source_to_virtual_text_handler = function(namespace, bufnr, diagnostics, opts)
  local diagnostics_with_source = vim.tbl_map(function(diagnostic)
    local source = diagnostic.source or ""
    -- if source contains non char at the last, remove it.
    source = string.gsub(source, '[^%w]$', '')
    source = get_formal_source_name(source)
    diagnostic.message = source and source .. ": " .. diagnostic.message
        or diagnostic.message

    return diagnostic
  end, vim.deepcopy(diagnostics))

  original_virtual_text_function_show(namespace, bufnr, diagnostics_with_source, opts)
end

function M.setup()
  -- local signs = { Error = '', Warn = '', Hint = '', Info = '' }
  local signs = { Error = 'E', Warn = 'W', Hint = 'H', Info = 'I' }

  vim.diagnostic.config({
    float = {
      border = 'single',
    },
    severity_sort = true,
    signs = signs == false and false or true,
    underline = true,
    update_in_insert = false,
    virtual_text = false,
    -- virtual_text = {
    --   severity = vim.diagnostic.severity.ERROR,
    --   spacing = 1,
    --   prefix = '■',
    -- },
  })

  -- vim.diagnostic.handlers.underline = {
  --   show = M.remove_multiline_underline_handler,
  --   hide = vim.diagnostic.handlers.underline.hide,
  -- }

  -- vim.diagnostic.handlers.virtual_text = {
  --   show = M.add_source_to_virtual_text_handler,
  --   hide = vim.diagnostic.handlers.virtual_text.hide,
  -- }

  if type(signs) == 'table' then
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end
  end

  vim.api.nvim_create_user_command('UserLspDiagnosticDisable', function()
    vim.diagnostic.disable()
  end, {})
  vim.api.nvim_create_user_command('UserLspDiagnosticEnable', function()
    vim.diagnostic.enable()
  end, {})
end

return M
