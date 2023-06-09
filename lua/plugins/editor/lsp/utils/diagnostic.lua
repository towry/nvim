local M = {}

function M.setup()
  local signs = { Error = '', Warn = '', Hint = '', Info = '' }

  vim.diagnostic.config({
    severity_sort = true,
    signs = signs == false and false or true,
    underline = true,
    update_in_insert = false,
    virtual_text = {
      prefix = ' :',
    },
  })

  if type(signs) == 'table' then
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end
  end
end

return M
