local M = {}

M.DiagnosticIcons = {
  error_icon = 'E',
  warn_icon = 'W',
  info_icon = 'I',
  hint_icon = 'H',
}

function M.setup()
  local S = vim.diagnostic.severity
  local signs = {
    text = {
      [S.ERROR] = M.DiagnosticIcons.error_icon,
      [S.WARN] = M.DiagnosticIcons.warn_icon,
      [S.HINT] = M.DiagnosticIcons.hint_icon,
      [S.INFO] = M.DiagnosticIcons.info_icon,
    },
  }
  local enable_virtual_text = false
  local virtual_text = enable_virtual_text
      and {
        severity = vim.diagnostic.severity.ERROR,
        spacing = 1,
        prefix = '■',
        -- right_align | overlay | eol | inline
        -- virt_text_pos = 'right_align',
      }
    or false

  vim.diagnostic.config({
    float = {
      border = 'single',
      focused = false,
      style = 'minimal',
      source = 'always',
    },
    severity_sort = true,
    -- @see https://github.com/neovim/neovim/pull/26193
    signs = signs,
    underline = true,
    update_in_insert = false,
    virtual_text = virtual_text,
  })

  if enable_virtual_text then
    local diagnostic_ns = vim.api.nvim_create_augroup('dia_insert', { clear = true })
    -- Display diagnostics as virtual text only if not in insert mode
    vim.api.nvim_create_autocmd('InsertEnter', {
      pattern = '*',
      group = diagnostic_ns,
      callback = function()
        vim.diagnostic.config({
          virtual_text = false,
        })
        if not enable_virtual_text then
          vim.api.nvim_create_augroup('dia_insert', { clear = true })
          return
        end
      end,
    })
    vim.api.nvim_create_autocmd('InsertLeave', {
      pattern = '*',
      group = diagnostic_ns,
      callback = function()
        if not enable_virtual_text then
          return
        end
        vim.diagnostic.config({
          virtual_text = true,
        })
      end,
    })
  end

  vim.api.nvim_create_user_command('UserLspDiagnosticDisable', function()
    vim.diagnostic.disable()
  end, {})
  vim.api.nvim_create_user_command('UserLspDiagnosticEnable', function()
    vim.diagnostic.enable()
  end, {})
end

return M
